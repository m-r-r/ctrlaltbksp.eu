---
layout: php-page
languages:
    fr:
        title: Contact
    eo:
        title: Kontatki min
featured: 4
allow_robots: false
sitemap: false
---
<?php
const DOMAIN = 'ctrlaltbksp.eu';

$success = filter_input(INPUT_GET,    'success',        FILTER_VALIDATE_BOOLEAN, true);
$email   = filter_input(INPUT_POST,   'email',          FILTER_VALIDATE_EMAIL,   true);
$name    = filter_input(INPUT_POST,   'name',           FILTER_SANITIZE_STRING,  true);
$message = filter_input(INPUT_POST,   'message',        FILTER_SANITIZE_STRING,  true);
$method  = filter_input(INPUT_SERVER, 'REQUEST_METHOD', FILTER_SANITIZE_STRING,  true);
$ip      = filter_input(INPUT_SERVER, 'REMOTE_ADDR',    FILTER_SANITIZE_STRING,  true);


$missing_fields = (!$email || !$name || !$message);

if ($method == 'POST' && !$missing_fields) {
  $headers = "From: $name <$email>\r\n";
  $message = "Ip: $ip\nDate: " . date('Y-m-d H:i:s') . "\n\n" . wordwrap($message, 75);
  $sent = mail('{{ site.author.email }}', '{%t Formulaire de contact %}', $message, $headers);
  if (true !== $sent) {
    ob_end_clean();
    header('HTTP/1.1 500 Internal Server Error');
    exit(0);
  }
  else {
    ob_end_clean();
    header('HTTP/1.1 303 Redirection');
    header('Location: {{ site.url }}{{ page.url }}?success=true');
    exit(0);
  }
}

if ($method == 'GET' && $success) { ?>
  <div class="success message">
    <h2 class="h6">{% t Message envoyé %}</h2>
    <p>{% t Vous recevrez une réponse par e-mail dès que possible. %}</p>
  </div>
<?php } else if ($method == 'POST' && $missing_fields) { ?>
  <div class="error message">
    <h2 class="h6">{% t Envoi impossible %}</h2>
    <p>{% t Veuillez remplir tous les champs du formulaire, et entrer une adresse e-mail valide %}</p>
  </div>
<?php } ?>
<?php if (!$success) : ?>
  <form action="#" method="POST">
    <div class="entry">
      <label for="name">{% t Nom : %}</label>
      <input type="text" required="required" name="name" id="name" placeholder="{% t Votre nom %}" /><br />
    </div>
    <div class="entry">
      <label for="email">{% t E-Mail : %}</label>
      <input type="text" required="required" name="email" id="email" placeholder="{% t Votre adresse mail %}" /><br />
    </div>
    <label for="message">{% t Message : %}</label><br />
    <textarea required="required" name="message" id="message" placeholder="{% t Entrez votre message ici %}"></textarea><br />
    <input type="submit" value="{% t Envoyer ! %}" />
  </form>
<?php endif; ?>
