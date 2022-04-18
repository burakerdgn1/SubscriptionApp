const functions = require("firebase-functions");
const admin = require("firebase-admin");
const request = require("graphql-request");

const client = new request.GraphQLClient("https://abonelik-app.hasura.app/v1/graphql", {
  headers: {
    "content-type": "application/json",
    "x-hasura-admin-secret": "SrD358JNlxzRhPflIvjgg1UhBGuO5Ew4bwPVYchxikrbZVNYaq2V45B8bDEr5KN9",
  },
});

admin.initializeApp(functions.config().firebase);
