<div id="top"></div>

<!-- BRANCH TITLE -->

# Branch 5: Debugging

<!-- Navigation -->
<details>
  <summary>Navigate between branches</summary>  
  <nav class="menu">
    <li><a href="https://github.com/manighahrmani/hangman-in-branches">Intro</a></li>
    <li><a href="https://github.com/portsoc/hangman-in-branches/tree/0">0: Variables</a></li>
    <li><a href="https://github.com/portsoc/hangman-in-branches/tree/1">1: Functions</a></li>
    <li><a href="https://github.com/portsoc/hangman-in-branches/tree/2">2: NPM</a></li>
    <li><a href="https://github.com/portsoc/hangman-in-branches/tree/3">3: DOM</a></li>
    <li><a href="https://github.com/portsoc/hangman-in-branches/tree/4">4: Events</a></li>
    <li>5: Debugging (this branch)</li>
    <li><a href="https://github.com/portsoc/hangman-in-branches/tree/6">6: Canvas</a></li>
    <li><a href="https://github.com/portsoc/hangman-in-branches/tree/7">7: Modularisation</a></li>
    <li><a href="https://github.com/portsoc/hangman-in-branches/tree/8">8: Server Part 1</a></li>
    <li><a href="https://github.com/portsoc/hangman-in-branches/tree/9">9: Server Part 2</a></li>
    <li><a href="https://github.com/portsoc/hangman-in-branches/tree/10">10: Style</a></li>
    <li><a href="https://github.com/portsoc/hangman-in-branches/tree/11">11: Linting</a></li>
    <li><a href="https://github.com/portsoc/hangman-in-branches/tree/12">12: Database</a></li>
    <li><a href="https://github.com/portsoc/hangman-in-branches/tree/13">13: SVG</a></li>
  </nav>
</details>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Contents of this branch</summary>
  <ol>
    <li><a href="#objectives">Objectives</a></li>
    <li><a href="#implementation">Implementation</a>
      <ol>
        <li><a href="#serve-the-website">Serve the website</a></li>
        <li><a href="#fix-issues">Fix issues</a></li>
        <ol>
          <li><a href="#non-alphabetical-symbols">Non alphabetical symbols</a></li>
          <li><a href="#repeat-guesses">Repeat guesses</a></li>
          <li><a href="#restart-game">Restart game</a></li>
        </ol>
      </ol>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#todo">Todo</a></li>
    <li><a href="#further-exploration">Further Exploration</a></li>
  </ol>
</details>

## Objectives

We will begin this branch by first serving the website using a basic Express server.
But our main focus will be on fixing the issues that were left open in the previous branch.

## Implementation

### Serve the website

To serve the website, we need to distinguish between what resources are for the server and what is for the client.
So we have made a client folder that includes:

```
client/
├── images
│   └── hangman.png
├── index.html
└── index.js
```

And a server folder that just includes a script for a basic Express server:

```
server/
└── svr.js
```

We have followed the installation guide on the [page for the Express package](https://www.npmjs.com/package/express) to install this as a dependency for our project.
This means that we have first navigated to the `hangman-in-branches` folder in the shell and then run the following command:

```
npm install express
```

This adds Express to the dependencies attribute of our `package.json` file and automatically creates the `package-lock.json` file.
For more info on what these files do check out [this page on `package.json`](https://docs.npmjs.com/cli/v8/configuring-npm/package-json) and [this page on `package-lock.json`](https://docs.npmjs.com/cli/v8/configuring-npm/package-json).

Installing Express will also create a `node_modules` folder in the hangman-in-branches.
This contains all the dependencies specific to the computer we are running the program in.
For this reason, we have not included `node_modules` in the repository (look for this in the `.gitignore` file).

Something else that happens once you install a package is that the dependencies will be added to the `package.json` file.
Take a look at this file and observe what is added to "dependencies" attribute.
As discussed in [the usage section](#usage), once you clone the repository and checkout this branch, you will need to run `npm install` which installs the dependencies.

Inside `package.json` we have manually added a `start` script as shown below.
It is a convention to set the `start` script to the shell command that starts the server:

```json
"scripts": {
  "start": "node server/svr.js"
}
```

Now by running `npm start` in the shell, we can see our site is being served in our machine over port 8080 (http://localhost:8080).
To stop the site, we can use <kbd>Ctrl</kbd> + <kbd>C</kbd> in the shell.

The last thing that we have added to `package.json` is the attribute `type` set to `module`.
This lets us use import statements (for more info check out [this documentation page](https://nodejs.org/docs/latest-v13.x/api/esm.html#esm_enabling)).

### Fix issues

#### Non alphabetical symbols

We start by using a regular expression to pick all the alphabetical characters in the word, replacing them with '\_'.
For more information read our comments in `startNewGame`.

Multiple spaces in HTML are rendered as a single space in the browser.
There are simple ways around it (e.g., using '\&nbsp;') but instead, the `redrawWord` function places each letter in a span element.
This decision will later allow us to treat letters individually (e.g., styling them differently).

#### Repeat guesses

To prevent the user from guessing the same letter twice, we have created `hits` and `misses` arrays.
We could have done it in one array but we would like to distinguish between them when it comes to styling the letters.

`registerLetter` now checks whether the new guess is in the `hits` or `misses` array and displays a message accordingly.
Every time the user makes a new guess, we call `redrawKeyboard` to update the keyboard accordingly.

#### Restart game

At the end of a game, we call `generateNewGame` function which will remove the keyboard and display a restart button.
When the user clicks the restart button, we call `startNewGame` to start a new game (resets the number of lives, chooses a new word and so on).
Consequently, `startNewGame` now calls `drawKeyboard` to create a new keyboard every time.

To see the new changes, [visit this compare page](https://github.com/portsoc/hangman-in-branches/compare/4...5?diff=split) showing the difference between branches 4 and 5.

## Usage

Run the following command to install all the dependencies:

```
npm install
```

Next, run the start script to start the server:

```
npm start
```

The website is now running locally on port 8080 so view it by visiting http://localhost:8080 in your browser.
Stop the server with <kbd>Ctrl</kbd> + <kbd>C</kbd> in the shell.

## Todo

This is our to-do list from the previous branch.
The tasks that are left to do are going to be addressed in later branches:

- [x] At the moment the user cannot win even if they guess all the letters correctly.

- [x] Another issue that we have is that the user can guess the same letter multiple times.

- [x] We have no way of restarting the game other than refreshing the page.

- [ ] We have too many global variables and it is hard to keep track of the game's state.

- [x] We are not currently serving our game from a server.

- [ ] The image of the hangman game is not updating as the game is being played.

## Further Exploration

The keys on the on-screen keyboard are not updating on time.
The user has to make a new guess for the previous letter to be registered and reflected on the keyboard.
Use what you have learned in the lessons to fix this issue.

**Hint:** Use your browser's developer tools and set breakpoints within the source code.
For more information, visit the documentation page on [breakpoints in Chrome](https://developer.chrome.com/docs/devtools/javascript/breakpoints/).
Check the content of hits and misses to see if they update on time or if the problem is from something else.

<p align="right">(<a href="#top">back to top</a>)</p>
