---
Title: Building a blog using Wyam, Azure DevOps and GitHub Pages
Published: 25/08/2019
Tags:
  - Wyam
  - Azure DevOps
  - GitHub Pages
---

I recently decided to start a personal blog and thought it might be
interesting to summarize how I set it up.
I took inspirtation in [Dave Glick's blog](https://daveaglick.com/) - both
in terms of styling as well as the tools used.

## Overview

This website is a static HTML site generated using [Wyam](https://wyam.io/).
The input is hosted on GitHub and I'm using Azure Pipelines to generate
the site and to publish it to GitHub Pages.

## Generating the site using Wyam

[Wyam](https://wyam.io/) is a .NET based static site generator.
As far as I can tell, it is pretty customizable but it has a number of presets
(called *Recipies*) and themes for common types of websites.

### Getting started

First, we need to install Wyam. It is available as .NET tool, so installing it
is as easy as running

```cmd
dotnet tool install -g Wyam.Tool
```

I decided to start out with the *Blog* template using the *CleanBlog* theme.
An empty website can be set up by running

```cmd
wyam new --recipe Blog
```

This creates a Wyam config file (`config.wyam`) an a sample first post for the blog:

```txt
C:.
│   config.wyam
│
└───input
    │   about.md
    │
    └───posts
            first-post.md
```

As you can see, posts are simply Markdown files in the `posts` directory.
To set the theme, add `#theme CleanBlog`  to the config file:

```cs
#recipe Blog
#theme CleanBlog

// Customize your settings and add new ones here
Settings[Keys.Host] = "host.com";
Settings[BlogKeys.Title] = "My Blog";
Settings[BlogKeys.Description] = "Welcome!";

// Add any pipeline customizations here
```

This is all it takes to get up and running. Wyam has an built-in webserver,
so you can preview the site by running `wyam --preview`.

<img src="./img/wyam-empty-blog.png"  alt="Wyam empty blog" width="90%" style="display: block; margin-left: auto; margin-right: auto; " />

### Customizing the template

While the default template already gives you quite a nice blog, I wanted
to customize it to fit my needs.

Any files in the theme can be overridden by placing a file with the same
name in your `input` directory. You find out which files to override you
can look at the [source code of the CleanBlog theme](https://github.com/Wyamio/Wyam/tree/develop/themes/Blog/CleanBlog) or at the [souce code of Dave Glick's blog](https://github.com/daveaglick/daveaglick).

### Custom Navigation bar

I wanted to include links to my Twitter and GitHub profiles in the main
navigation bar. This can be achieved by placing a `_Navbar.cshtml` file
in the input:

```html
<li><a href="/">Home</a></li>
<li><a href="/about">About</a></li>
@if(Documents[Blog.BlogPosts].Any() && Context.Bool(BlogKeys.GenerateArchive))
{
    <li><a href="/posts">Posts</a></li>
}
<li><a href="https://twitter.com/ap0llo">Twitter</a></li>
<li><a href="https://github.com/ap0llo">GitHub</a></li>
```

As you can see, Wyam uses ASP.NET's *Razor* syntax for template files. The
first to links are static and point to the *Home* respectively *About* pages.

The third link takes you to the list of posts. It will only be shown, if there
are any blog posts and the `BlogKeys.GenerateArchive` setting is enabled
(This way ne could disable in posts list in the Wyam config file).

The last two links are static links to my Twitter and GitHub links.

### Custom Footer

To customize the footer, I started by copying the
[footer from Dave Glick's blog](https://github.com/daveaglick/daveaglick/blob/7136039276c4ca39387815430de708b5d56cbcfd/input/_Footer.cshtml)
and adjusting the GitHub and Twitter links.

Additionally, I wanted to include the version of the input files the
site was generated from

TODO: Include github source info

TODO:
- Custom layout

## Setting up GitHub Pages

- Create repo
- Custom domain

## Automate deployment using Azure Pipelines
