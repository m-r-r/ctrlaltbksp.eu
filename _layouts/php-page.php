<?php if (!ob_start()) exit(42); ?>
<!DOCTYPE html>
<html lang="{{ page.lang | default:site.lang }}">
  <head>
    {% include head.html %}
  </head>
<!--[if IE 6]><body class="{{ page.lang | default:site.lang }} class="ie6"><![endif]-->
<!--[if !IE 6]><!-->
  <body itemtype="http://schema.org/Blog" itemscope="itemscope">
<!--<![endif]-->
    {% include skip-links.html %}
    {% include header.html %}
    <section role="main" id="content" class="inner">
      <header>
        <h2>{{ page.title }}</h2>
      </header>
    {{ content }}
    </section>
    {% include footer.html %}
  </body>
</html>
