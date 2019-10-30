# Add a headless CMS to Jekyll

This setup is not yet another blog example, it's an example on how to build a layout using a headless CMS with Jekyll. I'm sure you can create a flat content-type with title, text and teaser image all by yourself. Follow this [kind of short, but detailed, tutorial](https://www.storyblok.com/tp/headless-cms-jekyll) to bring your static pages to life (for previews).

![Jekyll](https://img.storyblok.com/wrJXkdfvlNMItQLFNBt0wjWGp14=/764x0/f/39898/1419x322/a7d54ce659/jekyll-logo.png)

## What to expect?

The "end result" will include a teaser, grid and column (feature) layout including an rebuild API to trigger rebuilds using a GET request and loading the data from Storyblok.

![Use Storyblok with Jekyll](http://img.storyblok.com/cwzjFEcSbFdxmd-tLsBQHmQt0a4=/840x0/filters:filters:fill(FFFFFF):filters:format(jpeg)/f/51376/2864x1424/dd9febae49/asset-helloworld-jekyll.png)

## You want to start the repo without the tutorial?

1. Clone this repository

```bash
git clone git@github.com:storyblok/jekyll.git
```

2. Start the preview server

```bash
bundle install

bundle exec rackup config.ru -p 4000
```

3. [Sign-up](https://app.storyblok.com/#!/signup) to create your first space and receive the default set of components & first content entry.

![Onboarding](https://img.storyblok.com/xtWjoBTgRJ7mqkNrYyKrfaaulTs=/840x0/filters:filters:fill(FFFFFF):filters:format(jpeg)/f/51376/2874x1432/34f729ecf4/asset-start-your-server.png)

exchange the draft token with the one in the code examples - and enter your localhost address **http://localhost:4000/**

4. Rebuild **without** the preview server

The above preview server is not required at all - it only helps you to easily create your content and preview it "instantly". You can (of course) still generate static files - and you should in production.

```bash
bundle exec jekyll serve
```

<br>
<br>
<p align="center">
<img src="https://a.storyblok.com/f/39898/1c9c224705/storyblok_black.svg" alt="Storyblok Logo">
</p>