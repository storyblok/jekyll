The idea of Metalsmith is quite simple: "An extremely simple, pluggable static site generator". So in this quick walkthrough, we will have a look at how we can use the data from the Storyblok API with a Metalsmith project to create some pages. At the end of this article, you will have a [Metalsmith project](https://github.com/storyblok/metalsmith) which renders components filled with data from the Storyblok API.

LOGO

## We're about to use Storyblok as headless CMS - so what is it?

Let me start with a short explanation of Storyblok: It is a hosted headless CMS in which you can create nested components per content entry. The author of one content entry, therefore, can create components that act as Content-type like articles or products but also easily can create nestable components to create landing pages - but would allow you to add Storyblok to existing solutions to enrich your current content as well.

![Storyblok Explained](//a.storyblok.com/f/39898/2680x1401/5aed1f3d7c/storyblok-explained.png)

## What are we going to build?

During this article, we will use the default component `page` which acts as layout/content-type and the nested components teaser, grid and feature to create a sample layout for landing pages. You will receive this setup during this tutorial, however, if you've already created a space that structure is already available in the content entry with the name "home".

## Let’s start with Metalsmith

### Requirements
- Basic understanding of [Metalsmith](http://www.metalsmith.io/) itself
- [NodeJS](https://nodejs.org/)
- [NPM](https://www.npmjs.com/)
- Basic [Handlebars](http://handlebarsjs.com/) knowledge

### Installation

You can either use the [JavaScript API](https://github.com/segmentio/metalsmith#api) or their [CLI](https://github.com/segmentio/metalsmith#api) - we will go for the JavaScript API, actually we will use [one of their examples as starting point](https://github.com/segmentio/metalsmith/tree/master/examples/static-site).

You can either clone the whole repository to access their example or [use this link](https://minhaskamal.github.io/DownGit/#/home?url=https://github.com/segmentio/metalsmith/tree/master/examples/static-site) to download only that subfolder.

Navigate to your downloaded project and execute:

~~~
npm install 
~~~

Finally - let's startup your downloaded Metalsmith project, you could either use their Makefile (`make build`) or simply go with:

~~~
node index.js
~~~

By default you should now have a simple "blog setup".

If you're facing any troubles feel free to leave a comment below or check out their [Github Repository](https://github.com/segmentio/metalsmith/tree/master/examples/static-site).

![Storyblok ruby sdk](//a.storyblok.com/f/39898/1419x223/29521adbf7/rubysdk.png)

## Install the Storyblok Node JS SDK.

By [creating a new Storyblok space](https://app.storyblok.com/#!/signup) you should already have a basic setup of content components including teaser, grid, and feature which we're going to use in this tutorial.

To access data from Storyblok we will have to call the API to receive that data. The easiest way to do that in Metalsmith is to write a custom plugin and write some lines of JavaScript. We will use the [Storybloks NodeJs SDK](https://github.com/storyblok/storyblok-node-client) to load that data:

~~~
npm install storyblok-node-client --save
~~~

You should now have that dependency in your `package.json` - since we want to use it we have to require it in the index.js

~~~
const StoryblokClient = require('storyblok-node-client')
~~~

## Let's create a Storyblok space

If you're not registered already simply [sign up](https://app.storyblok.com/#!/signup) using the webinterface. You will be guided through the creating of your first space, generate the default set of components and a content entry called "home". You will also see the onboarding with some code examples in different programming languages by clicking on that "home" content entry.

IMG 

You will also see the draft token (sometimes called private token) which allows us to load draft versions of your content, you can copy that from one of the code examples or from your space dashboard. We will need this token in the next step, because we're about to load that example data!

## Create a simple plugin to inject Storyblok content entries in the Metalsmith "files".

To allow a generation of pages according to your content in Storyblok, we will write a custom plugin to load the data from the API. You can customize it as you want and transform the data as you need it. It uses the [Storyblok Content Delivery API](https://www.storyblok.com/docs/Delivery-Api/overview) and the endpoint [Stories](https://www.storyblok.com/docs/Delivery-Api/get-a-story) in this example. Add the plugin below in your `index.js` you can read the comments to see what's happening - you can also `console.log` the `response.body` to have a look at the JSON from the API.

~~~
/*******
*
* Custom Storyblok Plugin which uses the Storyblok Node Client
* to load every Story from the Content Delivery API and 
* inject the content entries written in Storyblok to the
* `files` for the Metalsmith workflow.
*
* Also Content-Types in Storyblok will be matched to layouts in
* Metalsmith.
*
*******/

const storyblok = (files, metalsmith, done) => {
  let metadata = metalsmith.metadata()

  let Storyblok = new StoryblokClient({
    privateToken: 'qR6GM4L0j1w4h2fFZiZ28Qtt'
  })

  Storyblok.get('stories', {
    version: 'draft', // change this to published for production build
    v: Date.now()
  })
  .then((response) => {

    // iterate through every Story created in Storyblok
    // and inject it's content into the metalsmith workflow by
    // creating a property -> property value pair for each
    // content entry. (http://www.metalsmith.io/#how-does-it-work-in-more-detail-)

    for (let index = 0, max = response.body.stories.length; index < max; index++) {
      let story = response.body.stories[index];
        
      // Metalsmith wants to create a file according to that key
      let key = story.full_slug + '/index.html'

      // the actual Content from Storyblok as value
      let value = story

      // "contents" needed otherwise "metalsmith-layouts" simply breaks.
      value['contents'] = new Buffer('', encoding='utf8') 

      // content type in storyblok equals to layout (page = page, post = post, ...)
      value['layout'] =  story.content.component + '.html'

      // assign new "file" from Storyblok to metalsmiths workflow
      files[key] = value
    } 

    // continue with normal workflow
    setImmediate(done)
  })
  .catch((error) => {
    console.log(error)
  })
}
~~~

## Use your custom plugin

Since everything in Metalsmith is done using plugins, all we need to do is to tell Metalsmith to also use our `storyblok` plugin. You can do this by simply adding `.use(storyblok)` to their plugin chain.

~~~
Metalsmith(__dirname)
  .metadata({
    title: "My Static Site & Blog",
    description: "It's about saying »Hello« to the World.",
    generator: "Metalsmith",
    generator_url: "http://www.metalsmith.io"
  })
  .use(storyblok) // Your custom storyblok plugin.
  .source('./src')
  .destination('./build')
  .use(markdown())
  .use(layouts({
    engine: 'handlebars'
  }))
  .build(function(err, files) {
    if (err) { throw err }
    console.log('Build finished')
  })
~~~

## Our first custom layout

Since the default Metalsmith setup ships with `layouts/post.html` and `layouts/layout.html` we simply reuse that structure by adding our own layout. The root component (eg. content-type) by default in Storyblok is called "page". By accessing the API of Storyblok you can already see that `page` component.

You can create as many content-types as you want, to allow different layouts and fieldsets (think of something like: `post`, `project` or similar). Let's focus on the `layouts/page.html` for now.

~~~
<html>
  <head></head>
  <body>

    <div class="root">
      <strong>Content-Entry</strong>
      <pre>{{ content }}</pre>
      <strong>Content-Entries Body field</strong>
      <pre>{{ content.body }}</pre>
    </div>

  </body>
</html>
~~~

You can see it's actually nothing more than simple HTML page using the rendering engine [Handlebars](http://handlebarsjs.com/) to output the loaded data from the Storyblok API. We're not using the field `contents` here since most plugins out there expect it to be a Buffer and would break if it is not (or if it was empty). However, you can change the behavior of the plugin as you like.

The custom plugin loads defines the `layout` according to the first component (content-type) in the content. As mentioned by default Storyblok comes with a content-type named "page". You can create new components such as this as you want. By creating a file `layouts/page.html` with the above content, you can see how the data you receive from Storyblok actually looks like. 

The page component contains a field called `body` which is a simple array of other (now with the flag nestable) components. Let's try to iterate through that array called `body` and output the containing components. I've removed the `<html>`, `<head>`, and `<body>` tag from the `page.html` contents beflow to reduce the length a little bit - simple replace it with the previous `<div class="root">`. 

~~~
<div class="root">
  <ul>
  {{#each content.body }}
    <li>{{component}}</li>
  {{/each}}
  </ul>
</div>
~~~

## Use Handlebars Partials to create reusable components

Handlebars ships with the possibility to define "partials", which are reusable code snippets. In Storyblok we call those reusable parts simply "Components", actually everything in Storyblok is a component - some are acting as content-types other are nestable - those are the nestable once. The content we received from the API already has the components (`teaser`, `grid` and `feature`) of which we saw two already above. Now let's switch to the Handlebars partials to allow dynamically add those new components.

In your `index.js` you can replace we will have to tell the `metalsmith-layouts` plugin that we're not only using `handlebars` but also their partials options, which is bascially adding a line to tell the plugin in which folder to look for our partials.

~~~
...
.use(layouts({
  engine: 'handlebars',
  partials: 'partials'  // <-- thats the line
}))
~~~

and of course we will have to iterate through those components and include them. Handlebars allows us to [dynamically include partials](http://handlebarsjs.com/partials.html#dynamic-partials) by default.

~~~
<div class="root">
  {{#each content.body }}
    {{> (lookup . 'component') }}
  {{/each}}
</div>
~~~

We're about to include `teaser` and `grid` as those are the components we could see before, to allow [Handlebars](https://handlebarsjs.com/) to include them, we need to create the files in the folder `partials`.

### Create `partials/teaser.html` and `partials/grid.html`

Above we can see that all information for one such component is in the `blok` property and therefore we are able to access all information of a component like shown below:

~~~
<div>
  This is a <strong>{{component}}</strong> and has those fields: {{this}}
</div>
~~~

### Use the fields of the teaser component

We can now see that every field defined in Storyblok for one component can be used as a property in Handlebars partial files. Let's access the `headline` field of the `teaser` component and output it as an actual headline not just as a JS object above, simply change the content of the `partials/teaser.html` to:

~~~
<div class="teaser">
  <h1>{{headline}}</h1>
</div>
~~~

### The Grid: Let's move on to nested components

The `grid` Storyblok already comes with, is a component with an array field called `body`, similar to the `page` component. Currently, its only purpose is to allow a nesting, so let's iterate through that field. As in the `teaser` before we will access the `body` simply using the `body` property passed as context by Handlebars during the include in `layouts/page.html`.

~~~
<div class="grid">
  <ul>
  {{#each body }}
    <li>{{component}}</li>
  {{/each}}
  </ul>
</div>
~~~

You should now be able to see the name of the next nested components `feature`. We also need a file for that particular component in the `partials` folder as well, otherwise we won't be able to include it.

### Nested component "feature"

You can create as many components with as many fields as you like - so you're not limited to those we've just created for you to get started faster. Create more components, nest them and arrange them to beautiful landing pages or enrich existing pages or posts, or create new component as content-type for things like posts, projects and similar. 

Let's get back to the `feature` component for now: Same as with the `teaser` and `grid` we can simply create a new file in `partials` called `feature`.

~~~
<div class="column">
  <h3>{{ name }}</h3>
</div>
~~~

and replace the content of the `grid.html` component to actually include the nested `feature` components:

~~~
<div class="grid">
  {{#each body }}
    {{> (lookup . 'component') }}
  {{/each}}
</div>
~~~

## Well done! Lets prepare editing!

Now you should have seen the key concept of Storyblok and our nested components, if you only need flat structures simply create a new component as content-type and add your required fields directly.

The next big thing is the way you and your content creators will be able to edit the content of such components. For this purpose, we will now add the [Storyblok JavaScript Bridge](https://www.storyblok.com/docs/Guides/storyblok-latest-js) you may have already seen in the Onboarding (Step 2) of Storyblok.

Simply add the line below or from the onboarding in the bottom of your `page.html` - right before the closing `</body>` tag.

~~~
<script src="//app.storyblok.com/f/storyblok-latest.js" type="text/javascript"></script>
~~~

Now we need to update our components, in the draft version of the content from the Storyblok API each component ships with a `_editable` property - containing an HTML comment, place this right before every `components.html` like we did in the `teaser` below:

~~~
{{blok._editable}}
<div class="teaser">
  <h2>{{blok.headline}}</h2>
</div>
~~~

You can have a look at the HTML comment we've prepared there - it provides all the data the Storyblok JavaScript Bridge needs to tell the editor which component you've just clicked without messing up your own HTML, because it's only a comment.

## Rebuild on content change

You can skip this - if you don't want to have an instant preview and prefer to run Metalsmith everytime in the console to see your changes - this won't be used in production (because you don't need that instant preview) and is not necessary to use the data added in Storyblok. You can also use our [Webhooks](https://www.storyblok.com/docs/Guides/using-storyblok-webhooks) to trigger a build pipeline.

Since Metalsmith generates static files we somehow **need to trigger a rebuild** after a **save or publish event** was fired in Storyblok to have an instant preview. To do so we're using the **Events** of the [Storyblok JavaScript Bridge](https://www.storyblok.com/docs/Guides/storyblok-latest-js#events), simply add those lines below the script that you've included before.

~~~
<script>
storyblok.init()
storyblok.on('change', function() {
  function getAjax(url, success) {
      var xhr = window.XMLHttpRequest ? new XMLHttpRequest() : new ActiveXObject('Microsoft.XMLHTTP');
      xhr.open('GET', url);
      xhr.onreadystatechange = function() {
          if (xhr.readyState>3 && xhr.status==200) success(xhr.responseText);
      };
      xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
      xhr.send();
      return xhr;
  }
  getAjax('/rebuild', function(data){
    console.log(data)
    window.location.reload()
  })
})
</script>
~~~

You notice that it will call the `/rebuild` route, which isn't available using a default Metalsmith setup because there is no server running. To allow us doing that we're about to add a simple [Express server](https://github.com/expressjs/express) that serves the generated static files and allows us to trigger Metalsmith using a simple GET call. So let's install express using NPM.

~~~
npm install express --save
~~~

We're now able to add some more JS to our `index.js`. We'll have to require `express` and add some lines of JavaScript to configurate our express server.

~~~
/******
*
* Simple Express App to serve the static files
* trigger rebuilds via /rebuild to allow
* instant previews.
*
******/

const express  = require('express')
const app  = express()
const port = 4000

// Serve the folder "build"
app.use(express.static('build'))

// Allows us to trigger the rebuild using a simple
// GET request from everywhere if the express server
// is running.
app.get('/rebuild', (req, res) => {
  res.write('Rebuild Started\n');
  console.log('Rebuild Started');

  build(() => { 
    console.log('Rebuild done');
    res.write('Rebuild done');
    res.end()
  })
})

// Listen to Port 4000 and start initial build
app.listen(port, () => {
  console.log('Rebuild Server listening on %s ...', port)
  console.log('Initial build started')
  build(() => { console.log('Initial build ended') })
})
~~~

You can see that we're calling a function `build` which has another function as parameter. You can wrap your Metalsmith task in a function and instead of writing "Build finished" in the console we simply call that function - so let's update that. You can change the way we did that in this example anytime - feedback in Github or as comment down below appreciated.

~~~
const build = (finish) => {
  Metalsmith(__dirname)
  .metadata({
    title: "My Static Site & Blog",
    description: "It's about saying »Hello« to the World.",
    generator: "Metalsmith",
    generator_url: "http://www.metalsmith.io",
  })
  .use(storyblok)
  .source('./src')
  .destination('./build')
  .use(markdown())
  .use(layouts({
    engine: 'handlebars',
    partials: 'partials'
  }))
  .build(function(err, files) {
    if (err) { throw err }
    finish()
  })
}
~~~

Now we can start our NodeJS app just like before, but now it will also start an Express server 

~~~
node index.js
~~~

You can extract that Express part into another `.js` file like `preview.js` and or define a task that you can start for that preview purpose - to keep that tutorial short I've just extended my current `index.js` to showcase the basic idea.

**You won't need this in production** or wherever you want to publish your pages, this express server only needs to run **to allow an instant preview** since you don't want to run a command yourself everytime you've changed something in Storyblok. Of course, you could go with a command every time, or once after you've added your changes - but using it like this you will be much faster during content creation, because you see what you change!

## Embed your local environment as preview source

The last step in the onboarding, and to finally allow you to edit your components in that visual editor, you can simply enter [http://localhost:4000/](http://localhost:4000/) in the input at the onboarding screen. It will switch to your local address directly - you can change that later in your space settings of course.

IMG

I've added some [simple styles](https://rawgit.com/DominikAngerer/486c4f34c35d514e64e3891b737770f4/raw/db3b490ee3eec14a2171ee175b2ee24aede8bea5/sample-stylings.css) to the components to make it look better than plain HTML. 
Simply include those styles to your project and you should see the screen below if you're working in Storyblok, you can change the appearance of all components as you want - since Storyblok only provides the content you're free to do whatever you want with that content.

## Summary

Using Storyblok as your CMS with Metalsmith is, as you can see, just loading JSON instead of Markdown files. The visual editor can be plugged-in pretty straightforward and only needs a small amount of additional code for that instant rebuild. I really liked using Metalsmith because the idea of adding more functionality via plugins to allow that kind of flexibility is as flexible as Storyblok itself. I would love to receive and read your feedback and maybe have a look at some of your implementations. As always you can download the whole [source code from Github](https://github.com/storyblok/metalsmith) and comment below.