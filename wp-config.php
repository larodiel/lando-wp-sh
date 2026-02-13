<?php

/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the web site, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * MySQL settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://wordpress.org/support/article/editing-wp-config-php/
 *
 * @package WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //
$lando_info = json_decode(getenv('LANDO_INFO'));

/** The name of the database for WordPress */
define('DB_NAME', $lando_info->database->creds->database);

/** MySQL database username */
define('DB_USER', $lando_info->database->creds->user);

/** MySQL database password */
define('DB_PASSWORD', $lando_info->database->creds->password);

/** MySQL hostname */
define('DB_HOST', $lando_info->database->internal_connection->host);

/** Database charset to use in creating database tables. */
define('DB_CHARSET', 'utf8');

/** The database collate type. Don't change this if in doubt. */
define('DB_COLLATE', '');

/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 *
 * @since 2.6.0
 */

define('AUTH_KEY', 'u-#?mXn9-!yU{lb%![|7h-1b-OfiyV|RoK6d<;vT4x{bXu,7*ypo4q++bNp2G#K%');
define('SECURE_AUTH_KEY', 'ps647]$izDbjJ4~;OGX;VS[QDYZ=^i*`Hn-(i+ieII;<-@Dim0R=bVxb!enwo}{Q');
define('LOGGED_IN_KEY', 'xcDT1L7TeA.s_m]+$<7yRi{rYV5,po).{(Y_.6m) w7RJ27a@)Siv<SN1E2V0+#Z');
define('NONCE_KEY', 'Lj$qy!IQ6*f2#e5?[)vA+edg%#J)CYB:a]DbMXWiu6+Y)EhYb[hhc|.7+wtY/[|d');
define('AUTH_SALT', '*[SBw.Q+}O8wxY*>kH+bIe,-AQ_d~J:t07wCdS1YE3(:7zsqv>51C6WTkl*#*<MQ');
define('SECURE_AUTH_SALT', ' uUH;8Y`-2y}$6D0q0t)/22AT~_1|RdF3z H{^AVXs|-@X9_DO`D+Ye[eKlMjl<V');
define('LOGGED_IN_SALT', 'A<Pl|5J*udEu~&D[tJ5Tng@j&&=K#TG?]AO4yk:1HbkhvmN^,.v]Y[E>3p-Au9VS');
define('NONCE_SALT', '#-: A^mh%~Nou*/.k+MEgM%TkMfNDWgJ?>v4E}s$0BHK8L9w4F3a/C>X >QIr;F_');


/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://wordpress.org/support/article/debugging-in-wordpress/
 */
define('WP_DEBUG', true);
define('SCRIPT_DEBUG', true);

/* Add any custom values between this line and the "stop editing" line. */



/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if (! defined('ABSPATH')) {
    define('ABSPATH', __DIR__ . '/');
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
