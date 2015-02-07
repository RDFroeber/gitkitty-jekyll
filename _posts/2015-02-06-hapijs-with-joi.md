---
layout: post
title: 'hapi.js: API documentation and validation with joi and swagger'
---

## so much joi

So I definitely wasn't planning on writing a post today but had some free time and I just had to share! I've been playing around with [Hapi.js](http://hapijs.com/). Hapi is an HTTP server framework for Node.js (similar to Express) that was developed by [Eran Hammer](https://twitter.com/eranhammer) and the team at WalmartLabs. Hapi was developed with the idea in mind that configuration is better than code, meaning you should only need to add configuration options to the plugins you use with minimal code modifications. So plugins are a critical part of the framework and of this post. The two plugins I'm going to focus on today are [joi](https://github.com/hapijs/joi), maintained by Nicolas Morel, and [hapi-swagger](https://github.com/glennjones/hapi-swagger), by Glenn Jones.

<!--br-->
<div class="message-center">
  Disclaimer: This is not a getting started tutorial, but you can find one <a href="http://hapijs.com/tutorials">here</a>.
</div>

## joi, the coolest JavaScript object validator

First let's look at basic route in Hapi. The object `crtl.students` is coming from my required students controller module that contains all student methods.

{% highlight js %}
{
  method: 'GET',
  path: '/students/{id}',
  config: {
    handler: ctrl.students.findById
  }
}
{% endhighlight %}

This is very basic and if I do say so myself easy to read. I have all of my API routes contained in one array and while it's not the cleanest when you add object validation in, it's still pretty accessible. So now let's require joi and add some object&mdash;or in this case parameter&mdash;validation.

{% highlight js %}
{
  method: 'GET',
  path: '/students/{id}',
  config: {
    handler: ctrl.students.findById,
    validate: {
      params: {
        id: Joi.string().alphanum().required()
      }
    }
  }
}
{% endhighlight %}

See easy! That probably doesn't seem like a big deal. Joi is just making sure that a parameter exists in the request and that it only contains numbers and letters. <span class="accent">#totesbasic</span> 

However, what if we were creating a student, which has a fairly complex schema? It would be really cool to be able to do this:

{% highlight js %}
create: function(request, reply){
  var student = request.payload;

  Student.create(student, function(err, newStudent){
    if(err){
      return reply(err).code(400);
    } else {
      return reply(newStudent).code(201);
    }
  });
}
{% endhighlight %}

...and not have to worry about data integrity. Yeah, pretty awesome. So this, in my opinion, is where joi really shines. &#9734;

{% highlight js %}
{
  method: 'POST',
  path: '/students',
  config: {
    handler: ctrl.students.create,
    description: 'Creates a Student', // We'll talk about these options in relation
    tags: ['api', 'students'],        // to the hapi-swagger module later
    validate: {
      payload: {
        firstName: Joi.string().trim().min(3).max(100),
        lastName: Joi.string().trim().min(3).max(100),
        email: Joi.string().email().trim().required(),
        picture: Joi.string().trim().min(8).max(100),
        gender: Joi.string().valid('female', 'male', 'undisclosed'),
        google: {
          token: Joi.string().token(),
          id: Joi.string().alphanum()
        },
        address: {
          street: Joi.string().trim().min(20).max(150),
          city: Joi.string().trim().min(3).max(50),
          state: Joi.string().trim().length(2),
          zipcode: Joi.string().trim().length(5)
        },
        phone: Joi.string().regex(/(\(?[0-9]{3}\)?|[0-9]{3}).?[0-9]{3}.?[0-9]{4}/, 'US number'),
        gradYr: Joi.number().integer().min(4).max(4),
        degree: Joi.string().alphanum(),
        track: Joi.string().trim().min(3).max(50),
        semesters: Joi.array().includes(
          Joi.object().keys({
            date: Joi.string().trim().min(9).max(11).required(),
            complete: Joi.boolean(),
            courses: Joi.array().includes(
              Joi.object().keys({
                course: Joi.string().alphanum(),
                section: Joi.string().trim().min(3).max(50),
                status: Joi.string().valid('active', 'completed', 'dropped'),
                grade: Joi.string().trim().min(1).max(4),
              })
            )
          })
        )
      }
    }
  }
}
{% endhighlight %}

Ok that's a lot to take in but let's just highlight the big things.

* Enforced data structure
* Type validation, including more specific types like alphanumeric and integers
* Regex pattern matching
* Content validation
* A granular level of data formating with options like min and max string characters

All in all, it's pretty cool. Now let's get real crae and add happi-swagger.

## hapi + swagger

You've probably at least heard of [Swagger](http://swagger.io/) even if you're not really familiar with it. Swagger basically builds a representation (UI + API) of your RESTful API based on your routes and metadata associated with those routes. The hapi-swagger plugin can take a few options, but I decide to keep it simple for now and just use the version number.

{% highlight js %}
var pgk = require('./package.json');

server.register([
  {register: require('hapi-swagger'),
    options: {
      apiVersion: pgk.version
    }
  },
  ... // More plugins
], function (err) {
  if(err) {
    throw err;
  }

  /**
   * Start Server
   **/

  server.start(function () {
    server.log('info', 'Server running at: ' + server.info.uri);
  });
});
{% endhighlight %}

That's it. That's all I had to do. Now I can navigate to '/documentation' and *behold* my masterpiece of an API! (too much?)

<img src="{{ site.baseurl }}public/swagger.jpg" alt="Swagger UI for students">

Well I thought it was pretty cool. &#9786; If you want to see more of the source code you can find it [here](https://github.com/RDFroeber/degree).

