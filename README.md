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
