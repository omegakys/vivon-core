package com.vivoninc.core;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.neo4j.core.Neo4jClient;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import jakarta.annotation.PostConstruct;

@Component
public class Neo4jInitializer {

    @Autowired
    private Neo4jClient neo4jClient;

    @PostConstruct
    @Transactional
    public void init() {
        try {
            System.out.println("Starting Neo4j initialization...");
            clearDatabase();
            testConnection();
            insertMockData();
            verifyData();

            System.out.println("Neo4j initialization completed successfully");
        } catch (Exception e) {
            System.err.println("Error during Neo4j initialization: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private void testConnection() {
        try {
            String result = neo4jClient.query("RETURN 'Connection successful' as message")
                    .fetchAs(String.class)
                    .mappedBy((typeSystem, record) -> record.get("message").asString())
                    .one()
                    .orElse("No result");
            System.out.println("Neo4j connection test: " + result);
        } catch (Exception e) {
            System.err.println("Neo4j connection failed: " + e.getMessage());
            throw e;
        }
    }

    private void clearDatabase() {
        try {
            System.out.println("Clearing existing data...");
            neo4jClient.query("MATCH (n) DETACH DELETE n").run();
            System.out.println("Database cleared");
        } catch (Exception e) {
            System.err.println("Error clearing database: " + e.getMessage());
        }
    }

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Transactional("neo4jTransactionManager")
    private void insertMockData() {

        System.out.println("Creating Neo4j users...");

        // ------------------------------------------------------------------
        // Create a User node for every MySQL user
        // ------------------------------------------------------------------

        List<Integer> userIds = jdbcTemplate.query(
                "SELECT id FROM users",
                (rs, rowNum) -> rs.getInt("id"));

        for (Integer id : userIds) {
            neo4jClient.query("""
                        MERGE (:User {id:$id})
                    """)
                    .bind(id).to("id")
                    .run();
        }

        System.out.println("Created " + userIds.size() + " users");

        // ------------------------------------------------------------------
        // Create Group nodes
        // ------------------------------------------------------------------

        List<Integer> groupIds = jdbcTemplate.query(
                """
                        SELECT id
                        FROM conversations
                        WHERE type='group'
                        """,
                (rs, rowNum) -> rs.getInt("id"));

        for (Integer id : groupIds) {

            neo4jClient.query("""
                        MERGE (:Group {id:$id})
                    """)
                    .bind(id).to("id")
                    .run();
        }

        System.out.println("Created " + groupIds.size() + " groups");

        // ------------------------------------------------------------------
        // Add IN_GROUP relationships
        // ------------------------------------------------------------------

        jdbcTemplate.query(
                """
                        SELECT cm.user_id,
                               cm.conversation_id
                        FROM conversation_members cm
                        JOIN conversations c
                             ON c.id = cm.conversation_id
                        WHERE c.type='group'
                        """,
                rs -> {

                    neo4jClient.query("""
                                MATCH (u:User {id:$user})
                                MATCH (g:Group {id:$group})
                                MERGE (u)-[:IN_GROUP]->(g)
                            """)
                            .bind(rs.getInt("user_id")).to("user")
                            .bind(rs.getInt("conversation_id")).to("group")
                            .run();
                });

        // ------------------------------------------------------------------
        // Every DM means the users are already friends
        // ------------------------------------------------------------------

        jdbcTemplate.query(
                """
                        SELECT
                            conversation_id,
                            GROUP_CONCAT(user_id ORDER BY user_id) members
                        FROM conversation_members
                        WHERE conversation_id IN (
                            SELECT id
                            FROM conversations
                            WHERE type='direct'
                        )
                        GROUP BY conversation_id
                        """,
                rs -> {

                    String[] users = rs.getString("members").split(",");

                    if (users.length == 2) {

                        int u1 = Integer.parseInt(users[0]);
                        int u2 = Integer.parseInt(users[1]);

                        neo4jClient.query("""
                                    MATCH (a:User {id:$u1})
                                    MATCH (b:User {id:$u2})
                                    MERGE (a)-[:FRIEND]-(b)
                                """)
                                .bind(u1).to("u1")
                                .bind(u2).to("u2")
                                .run();
                    }
                });

        // ------------------------------------------------------------------
        // Example pending friend request
        // ------------------------------------------------------------------

        neo4jClient.query("""
                    MATCH (a:User {id:4})
                    MATCH (b:User {id:1})
                    MERGE (a)-[:FRIEND_REQ]->(b)
                """).run();

        System.out.println("Neo4j mock data inserted.");
    }

    private void verifyData() {
        try {
            // Count nodes
            Integer nodeCount = neo4jClient.query("MATCH (n) RETURN count(n) as count")
                    .fetchAs(Integer.class)
                    .mappedBy((typeSystem, record) -> record.get("count").asInt())
                    .one()
                    .orElse(0);
            System.out.println("Total nodes in database: " + nodeCount);

            // Count relationships
            Integer relCount = neo4jClient.query("MATCH ()-[r]->() RETURN count(r) as count")
                    .fetchAs(Integer.class)
                    .mappedBy((typeSystem, record) -> record.get("count").asInt())
                    .one()
                    .orElse(0);
            System.out.println("Total relationships in database: " + relCount);

            // Check specific friend requests
            Integer friendReqCount = neo4jClient.query("MATCH ()-[:FRIEND_REQ]->() RETURN count(*) as count")
                    .fetchAs(Integer.class)
                    .mappedBy((typeSystem, record) -> record.get("count").asInt())
                    .one()
                    .orElse(0);
            System.out.println("Friend requests in database: " + friendReqCount);

        } catch (Exception e) {
            System.err.println("Error verifying data: " + e.getMessage());
            e.printStackTrace();
        }
    }
}