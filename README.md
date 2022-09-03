<div id="top"></div>

<!-- BRANCH TITLE -->

# Branch 13: SVG

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#objectives">Objectives</a></li>
    <li><a href="#implementation">Implementation</a>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#todo">Todo</a></li>
    <li><a href="#further-exploration">Further Exploration</a></li>
  </ol>
</details>

## Objectives

Data should be stored in a database.
But so far, we have been storing our data in memory (saved inside JavaScript variables).
In this branch, we will demonstrate how you can have a database inside a Node.js application.

## Implementation

Our data, so far, consists of the `gamesInPlay` and `words` arrays both located on the server.
They differ significantly in nature: `gamesInPlay` is dynamic in the sense that it is updated as games are created or played.
On the other hand, `words` array is an example of static data.
Our solutions to how we store our data will be different as a result.

To store the static data we are using a simple text file and for the dynamic data, we are using a PostgreSQL database.
The latter may be unnecessary, a non-relational database such as MongoDB or even a JSON file is better suited to store `gamesInPlay`.
Nevertheless, take our work here as an example of how to use a relational database in a Node.js application.

What is important to note is that everything in the `client` folder remains unchanged throughout all of our modifications.
At this stage, we do not want the client to know anything about the changes in our server (read [the further exploration section](#further-exploration) for more details).

### Static data

We have moved the array of `words` (previously in `server/data.js`) to a text file `server/data.txt`.
The words are now separated by a newline (`\n`) whereas before the array elements were separated by a comma (`,`).

To read the content of `server/data.txt`, we need to use the `fs` module.
Note that the module is native to Node.js, so we don't need to install anything.
The `readWords` function in `server/helper.js` uses the `readFileSync` function from the `fs` module to read the content of the data file synchronously.

### Dynamic data

To host a PostgreSQL database for our side, we obviously need to have PostgreSQL installed on our machines (being a good developer, we have pointed this out in the [usage section](#usage)).

Apart from this, we need to have a database for our data and a table in that database.
We are doing both of these tasks with the `setup` script we have added in `package.json`.

Same as how the `start` script runs a command to serve the website, the `setup` script first creates a Postgres database `hangmanDB` using the `createdb` command.
Next, it uses the input redirection operator (`<`) to pass the content of the newly created `server/game.sql` file to `psql`'s `hangmanDB`.
The content of `game.sql` should be familiar to you, it is creating our `game` table in the hangman database.

After this setup, we need to connect to the database and insert/look up and update data in the table via JavaScript.
To be able to do this, we need to install the [`pg` package](https://www.npmjs.com/package/pg) using the following command:

```bash
npm install pg
```

We point out that this adds a new entry to the "dependencies" section of `package.json` (therefore `npm install` will install the package).

Since we have modularized our server, we only need to import the `pg` module into the script which includes the game's logic: `server/game.js`.
There we will use the `pg` module's `Client` class.
For more information on `pg.Client`, check out [this documentation page](https://node-postgres.com/api/client).

First, we will construct an SQL client with the configurations defined in our `server/config.js` file.
Remember to check this file and comment out the `host` if you are running the server on your machine (leave it uncommented when running on your VM).
We could have left the configurations in `server/game.js` but it is more convenient to have them in a separate file.
After creating an SQL client we will attempt to connect to the database in the `connectToDB` function.
If the connection is established, we can use the client to query the database.

We have updated every function in `server/game.js` that previously used to deal with the `gamesInPlay` array.
For example `createGame`, now inserts the game's values into the database by querying the SQL client.

The only thing to be careful of, while interacting with the database, is that the arrays are stored as varchar in the database (see `server/game.sql`).
Therefore, we need to join arrays before inserting/updating them in the database and split them when we retrieve them.

Since the operation of querying the database is asynchronous, our functions have also been declared with the `async` keyword.
Sadly, this creates a problem in the `server/svr.js` script as [Expres routing](https://expressjs.com/en/starter/basic-routing.html) works differently for synchronous and asynchronous functions.
Previously, `createGame` was a synchronous function called as the response to the `\game\` path:

```js
app.post("/games/", createGame);
```

Now that `createGame` is asynchronous, our route handler must be changed to something like this:

```js
app.post("/games/", async (req, res) => {
  await createGame(req, res);
});
```

The only problem with the above handler is that it is assuming that the `createGame` function will always succeed.
To handle errors, Express needs our handler function to take an additional `next` parameter.

If you want to know more about what `next` function is or middleware in general, we recommend [this page](https://expressjs.com/en/guide/using-middleware.html).
Similarly, to learn about error handling in express routing, we suggest [this article](https://expressjs.com/en/guide/error-handling.html).

All you need to remember at this point is that our handler should catch possible errors and pass them to the next function as shown below:

```js
app.post("/games/", async (req, res, next) => {
  try {
    await createGame(req, res);
  } catch (e) {
    next(e || new Error());
  }
});
```

Using promises, we can now handle errors more compactly (removing the need for the `async` keyword):

```js
app.post("/games/", (req, res, next) => {
  Promise.resolve(createGame(req, res)).catch((e) => next(e || new Error()));
});
```

Surely we don't want to have to write all this code for every one of our routes.
So we have introduced the `asyncWrap` function.

```js
function asyncWrap(f) {
  return (req, res, next) => {
    Promise.resolve(f(req, res, next)).catch((e) => next(e || new Error()));
  };
}
```

There is a lot to take in so make sure to read the comments in the code.
Also, view all the differences between our current branch and the last by visiting [this compare page](https://github.com/portsoc/hangman-in-branches/compare/11...12?diff=split).

## Usage

### Prerequisites

This branch has been implemented to run in a Unix environment (e.g., your student VMs or Linux/macOS machines).
It is not tested on a Windows environment.
For more information on serving the site on [your student VM](http://port.ac.uk/myvm), revisit the [README of branch 9](https://github.com/portsoc/hangman-in-branches/tree/9#host-this-site).

We are also using [the PostgreSQL database](https://www.postgresql.org/download/) so make sure you have it installed on your machines (it is already installed on the student VMs).
Verify your installation by running the following command in a shell. It should output the version of PostgreSQL you are using:

```bash
psql --version
```

### Setup

Run the following command to install all the dependencies:

```bash
npm install
```

You also need to run the following command to set up the database and table:

```bash
npm run setup
```

Running the `setup` script may fail on your personal machines.
If this happens, begin by checking the configuration of the database in `server/config.js`.
Read the comments in this file and make sure you have the correct configuration.

If the error persists, switch the user in your shell by running the following command then re-run the setup script:

```bash
sudo su postgres
```

The above command (which will ask you for your system's password) will switch to the `postgres` user.
The `postgres` role comes with the installation of PostgreSQL and has all the privileges to create, drop, alter and modify databases.
When you are done with the setup, you can switch back to the original user by running:

```bash
exit
```

One last way the setup script can fail is if the database already exists.
To handle this error we have provided a clean-up script in `package.json` which will drop the database if it already exists.
See the [clean-up section](#cleanup) for more information.

### Run the server

Run the start script to start the server:

```bash
npm start
```

If you are running the server on your student VMs, you can now access it by visiting the IP address shown on the MyVM page or [upABCDEF.myvm.port.ac.uk](upABCDEF.myvm.port.ac.uk) where ABCDEF is replaced by your student number.
You may also need to specify the port by adding the port number to the end of the URL (e.g., [upABCDEF.myvm.port.ac.uk:8080](upABCDEF.myvm.port.ac.uk:8080)).

On your personal machines, the website will be running locally on port 8080 so view it by visiting http://localhost:8080 in your browser.

Once you are done, stop the server with <kbd>Ctrl</kbd> + <kbd>C</kbd> in the shell.

### Clean-up

The setup script creates a database that will not be removed unless you run the clean-up script.
Execute the clean-up script by running the following command in the 0shell:

```bash
npm run clean-up
```

## Todo

That's it.
We are done with our predefined tasks.
We still have [one more branch](https://github.com/portsoc/hangman-in-branches/tree/12) where we will replace our canvas with an SVG but our application will remain pretty much the same.

- [x] We still have not satisfied one of the core requirements of displaying how many moves it took to win as a score.

- [x] The server is only capable of handling one game at a time. We need to add a mechanism to handle multiple games simultaneously. This could be a nice additional feature (as suggested in [the coursework specification](https://docs.google.com/document/d/1cF3u2ldutHaBAzFOEsnVwfKrnPTylOrn-hAGFSDWca8/edit)).

- [x] `server/svr.js` should be split into multiple files (we need to modularize the code in our server too).

- [x] Data should be stored in a database. We need a better way to store `words` and maybe the state of games at play.

- [x] As we have almost met all the core requirements, we can start with the style of our website.

- [x] We should lint our code, checking its stylistic quality, before submission.

## Further Exploration

### Improve choice of databases

As pointed out before, storing the `gamesInPlay` in a relational database is not the best choice.
After all, we are only storing one entity so there are no relations between the data.
All we need is a collection of objects, not a relational database.

As a relatively easy challenge, we ask you to store the games in play as a JSON file as opposed to a PostgreSQL database.
You still need the `fs` module to read this file but remember to use [the JSON parse method](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/parse) to convert the data to a JavaScript object.

### Handle server errors

Indeed, we should not let the client know about the server's implementations.
However, we should be able to handle server errors (e.g., errors connecting to the database) and display a meaningful message to the client.

At the moment, the server (`server/svr.js`) responds with `null` if there was a database connection error in `server/game.js`.
What do you think the client sees in such a scenario?
Simulate this situation by running the clean-up script before starting the server or changing the database name in `server/config.js`.

A harsher alternative to responding with `null` is to kill the server with:

```js
process.exit(1);
```

Try it by uncommenting the line in the `connectToDB` function of `server/game.js` and see what happens when you start the server and try to access the website.

None of these two approaches are ideal.
So we are encouraging you to implement a middle ground where the server does not die but responds with a meaningful message to the client.
For example, the server can send the status code of 500 (Internal Server Error) and a message to the client.
The client can then display this message to the user so that they know what went wrong.

Check out [the server101 repository](https://github.com/portsoc/server101) for an example of how to handle errors.
Don't forget to prepare the client for the case where the server responds with an error.
The [messageboard repository](https://github.com/portsoc/staged-simple-message-board) is a simple example of how to handle errors on the client side.

<p align="right">(<a href="#top">back to top</a>)</p>
