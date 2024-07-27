const mysql2 = require("mysql2");

const connection = mysql2.createConnection({
    host: process.env.DATABASE_HOST,
    port: process.env.DATABASE_PORT,
    user: process.env.DATABASE_USER,
    password: process.env.DATABASE_PASSWORD,
    database: process.env.DATABASE_NAME
});

connection.connect(err => {
    if(err){
        console.error("Error Connection: ", err);
    }
    console.log("Successfully Connected To Database");
})

module.exports = connection