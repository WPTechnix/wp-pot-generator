<?php
/**
 * Plugin Name: Test Plugin
 * Text Domain: test-plugin
 */

function tp_hello() {
    return __( 'Hello World', 'test-plugin' );
}

function tp_admin() {
    return __( 'Admin text', 'test-plugin' );
}
