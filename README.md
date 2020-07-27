# syncMyShoppingList

Realm Demo App Install Guide:

1. Download Zip to Local Mac Directory
2. Install the Realm Frameworks with CocoaPods
    From the directory above, run the following command:
        pod init
3. If successfully run the following command to download the required packages:
        pod install --repo-update


// Create and configure Realm app
4. Create a new Atlas cluster (DB v4.4) and add a standalone or 3 node replica set 
5. Create a new Realm App - can call it anything e.g. shoppingList
6. Link Cluster created in step 4 and click Create

7. Rules 
    - Add Database: shoppingList
    - Add collection: users
    - Click Add Collection (leave the other defaults)
8. Add Schema:
{
  "title": "User",
  "required": [
    "_id",
    "_partition",
    "user_id",
    "list",
    "name",
    "created"
  ],
  "properties": {
    "_id": {
      "bsonType": "objectId"
    },
    "_partition": {
      "bsonType": "string"
    },
    "user_id": {
      "bsonType": "string"
    },
    "list": {
      "bsonType": "string"
    },
    "name": {
      "bsonType": "string"
    },
    "created": {
      "bsonType": "date"
    }
  }
}

9. Rules 
- Add Database: shoppingList (plus button next to cluster mongodb-atlas)
- Add collection: items
- Click Add Collection (leave the other defaults)

10. Add Schema:
{
  "title": "Item",
  "required": [
    "_id",
    "_partition",
    "name",
    "status",
    "created_by",
    "created"
  ],
  "properties": {
    "_id": {
      "bsonType": "objectId"
    },
    "_partition": {
      "bsonType": "string"
    },
    "name": {
      "bsonType": "string"
    },
    "status": {
      "bsonType": "string"
    },
    "created_by": {
      "bsonType": "string"
    },
    "created": {
      "bsonType": "date"
    },
    "updated_by": {
      "bsonType": "string"
    },
    "updated": {
      "bsonType": "date"
    }
  }
}

11. Users > Providers > Email/Password:
- Enable
- User Confirmation Method: Automatically
- Password Reset Method: Run a password reset function
- click + New function and accept default resetFunc 
- We aren't going to implement this functionality so just click save

12. Users > Custom User Data:
- Enable Customer User Data
- Enter following in "Store Customer User Data":
  + Select cluster name
  + Select Database name
  + Select Collection name
  + Enter User ID Field: user_id

13. Create New Function:
- Name: createNewUser
- Authentication: Application
- Private: On
- Click Save (leave other defaults)

- Enter code into function editor:
exports = async function createNewUserDocument({ user }) {
  const cluster = context.services.get("mongodb-atlas");
  const users = cluster.db("shoppingList").collection("users");
  return await users.insertOne({
    _partition: "ShoppingListApp",
    user_id: user.id,
    name: user.data.email,
    created: new Date()
  });
};

- Click Save

14. Create another function:
- Name: setUserList
- Authentication: Application
- Private: Off
- Click Save (leave other defaults)

- Enter code into function editor:
exports = async function setUserList(listName) {
  const cluster = context.services.get("mongodb-atlas");
  const users = cluster.db("shoppingList").collection("users");
  return await users.updateOne({
    _partition: "ShoppingListApp",
    //user_id: context.user.id
    user_id:context.user.id
  },{$set:{list:listName}});
   return {uId: context.user.id};
};

- Click Save

15. Create Trigger:
Trigger Type: Authentication
Name: onNewUser
Action Type: Create 
Providers: Email/Password
Event Type: Function
Function: createNewUser

16. > Sync:
- Select cluster created in step 4
- Select _partition as partition key
- Click enable Sync 

17. Review and Deploy

18. Set the REALM App ID in Xcode
