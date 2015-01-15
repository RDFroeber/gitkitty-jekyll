---
layout: page
title: About
permalink: /about/
---

This is the base Jekyll theme. You can find out more info about customizing your Jekyll theme, as well as basic Jekyll usage documentation at [jekyllrb.com](http://jekyllrb.com/)

You can find the source code for the Jekyll new theme at: [github.com/jglovier/jekyll-new](https://github.com/jglovier/jekyll-new)

You can find the source code for Jekyll at [github.com/jekyll/jekyll](https://github.com/jekyll/jekyll)

## Code

{% highlight js linenos %}
function checkForOrderId(userEmail, callback) {
  var optionReqsGetId = {
    email: userEmail,
    baseUrl: '/orders/temp',
    httpMethod: 'POST',
    // payload: '{}'
  };

  OptionsController.createOptions(optionReqsGetId.email, optionReqsGetId.baseUrl, optionReqsGetId.httpMethod, optionReqsGetId.payload, function(err, options) {
    request(options, function(err, response, body) {
      if (err) {
        return res.status(400).send(err);
      } else if (response.statusCode === 201) {
        callback(body);
      } else if (response.statusCode === 404) {
        res.status(response.statusCode).send();
      } else {
        res.send(response.statusCode, body);
      }
    });
  });
}
{% endhighlight %}

{% highlight css %}
abbr {
  font-size: 85%;
  font-weight: bold;
  color: #555;
  text-transform: uppercase;
}
abbr[title] {
  cursor: help;
  border-bottom: 1px dotted #e5e5e5;
}
{% endhighlight %}