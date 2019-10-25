# RESTful interface to the DCC DocDB tables in MySQL

This package implements a simple RESTful API to the DCC DocDB database using 
[Sequelize](https://sequelize.readthedocs.io/en/v3/) and
[Finale](https://github.com/tommybananas/finale).

## Examples

To get all authors:
```
[root@seaview /]# curl localhost:3000/Author -s0 | jq
[
  {
    "AuthorID": 1,
    "FirstName": "Duncan",
    "MiddleInitials": null,
    "LastName": "Brown",
    "InstitutionID": 50,
    "Active": 1,
    "TimeStamp": "2019-01-30T08:00:00.000Z",
    "AuthorAbbr": "dabrown",
    "FullAuthorName": "Duncan Brown"
  }
]
```

To create an author:
```
[root@seaview /]# curl localhost:3000/Author -X POST -d '{"FirstName" : "Josh", "LastName" : "Smith", "Active" : "1" }' -H 'content-type: application/json' -s0 | jq
{
  "InstitutionID": 0,
  "TimeStamp": "2019-10-25T17:05:28.000Z",
  "AuthorID": 8058,
  "FirstName": "Josh",
  "LastName": "Smith",
  "Active": 1,
  "MiddleInitials": null,
  "AuthorAbbr": null,
  "FullAuthorName": null
}
```

## References

 - [How to build a secure REST API with node.](https://developer.okta.com/blog/2018/08/21/build-secure-rest-api-with-node) This uses epilogue which is not compatible with Sequelize version 5. The solution is to switch from epilogue to [finale.](https://github.com/tommybananas/finale)
 - [Instructions on running an OAuth2 server](https://www.ory.sh/run-oauth2-server-open-source-api-security/) and [validating tokens]((https://www.ory.sh/docs/hydra/integration) from a node.js application.
