---
layout: php-page
title: Envoi
lang: fr
allow_robots: false
sitemap: false
---

<?php
const DATE_FORMAT = 'Y-m-d H:i:s';
const EMAIL_ADDRESS = 'raybaudroigm@gmail.com';
const SUBJECT = 'Commentaire';
const DOMAIN = 'ctrlaltbksp.eu';

$success = filter_input(INPUT_GET,    'success',        FILTER_VALIDATE_BOOLEAN, true);
$return_to = filter_input(INPUT_GET,  'return_to',      FILTER_SANITIZE_URL,     true);
$uri     = filter_input(INPUT_SERVER, 'PHP_SELF',       FILTER_SANITIZE_STRING,  true);
$method = filter_input(INPUT_SERVER,  'REQUEST_METHOD', FILTER_SANITIZE_STRING,  true);
$ip      = filter_input(INPUT_SERVER, 'REMOTE_ADDR',    FILTER_SANITIZE_STRING,  true);

$data = filter_input_array(INPUT_POST, array(
    'post_id' => FILTER_SANITIZE_STRING,
    'from' => FILTER_VALIDATE_EMAIL,
    'name' => FILTER_SANITIZE_STRING,
    'link' => FILTER_SANITIZE_URL,
    'message' => FILTER_SANITIZE_STRING
), true);
$missing_field = (!$return_to || !$data['post_id'] || !$data['name'] || !$data['message'] || !$data['from']);

$data['date'] = date(DATE_FORMAT);
$data['name'] = preg_replace('/\s+/m', ' ', $data['name']);


if ($method == 'POST' && !$missing_field) {
    $json_data = json_encode($data);

    $text_message  = 'Message de ' .$data['name'] . " ($ip):\r\n\r\n";
    $text_message .= wordwrap($data['message'], 75);

    # Encodage en base 64
    $json_data = chunk_split(base64_encode($json_data));
    $text_message  = chunk_split(base64_encode($text_message));

    # Génération d'un séparateur
    $boundary = md5(date(DATE_FORMAT));

    # Création d'un en-tête MIME multipart
    $headers  = 'From: '. $data['name'] . ' <' . $data['from'] . ">\r\n";
    $headers .= "Content-Type: multipart/mixed; boundary=\"$boundary\"\r\n";
    $headers .= "Content-Transfer-Encoding: 8bit\r\n";

    $json_filename = trim(preg_replace('/\W+/', '-', $data['post_id'] . '_' .$data['date']) . '.json', '-');

    $payload  = "This is a multi-part message in mime format.\r\n\r\n";
    $payload .= "--$boundary\r\n";
    $payload .= "Content-Disposition: inline\r\n";
    $payload .= "Content-Type: text/plain; charset=\"utf-8\"\r\n";
    $payload .= "Content-Transfer-Encoding: base64\r\n\r\n";
    $payload .= "$text_message\r\n\r\n";
    $payload .= "--$boundary\r\n";
    $payload .= "Content-Type: application/json; name=\"$json_filename\"\r\n";
    $payload .= "Content-Transfer-Encoding: base64\r\n";
    $payload .= "Content-Disposition: attachment\r\n\r\n";
    $payload .= "$json_data\r\n\r\n";
    $payload .= "--$boundary--";

    if ((true === mail(EMAIL_ADDRESS, SUBJECT, $payload, $headers)) || !$uri) {
        ob_end_clean();
        header('HTTP/1.1 500 Internal Server Error');
        exit;
    }
    else {
        ob_end_clean();
        header('HTTP/1.1 303 Redirection');
        header("Location: http://".DOMAIN."/$uri?return_to=$return_to&success=true");
        exit;
    }
}
if ($method == 'GET' && $success) { ?>
<div class="success message">
  <h2 class="h6">Message envoyé</h2>
  <p>
    Votre message à bien été envoyé.<br />
    Il est maintenant en attentre de modération et sera affiché dès que
    l'administrateur du site l'aura lu.
  </p>
  <?php if ($return_to): ?>
  <p>
    Cliquez <a href="<?= $return_to ?>">ici</a> pour revenir en arrière.
  </p>
  <?php endif; ?>
</div>
<?php } else if ($method == 'POST') { ?>
<div class="error message">
  <h2 class="h6">Envoi impossible</h2>
  <p>
    Votre message n'a pas pu être envoyé.
  </p>
  <p>
    Assurez vous d'avoir bien rempli tous les champs.<br />
    Si le problème persiste, vous pouvez contacter le propriétaire
    du site <a href="/contact.html">ici</a>.
  </p>
  <?php if ($return_to): ?>
  <p>
    Cliquez <a href="<?= $return_to ?>">ici</a> pour revenir
    au formulaire.
  </p>
  <?php endif; ?>
</div>
<?php
} else { 
  ob_end_clean();
  http_response_code(404);
  header('HTTP/1.1 404 Not Found');
  exit;
}
?>
