<?php

use CodeIgniter\Router\RouteCollection;

/** @var RouteCollection $routes */
$routes->get('/', 'Home::index');

$routes->group('api', function ($routes) {
    $routes->get('umkm', 'Api\UmkmController::index');
    $routes->get('umkm/(:num)', 'Api\UmkmController::show/$1');
    $routes->post('umkm', 'Api\UmkmController::create');
    $routes->put('umkm/(:num)', 'Api\UmkmController::update/$1');
    $routes->delete('umkm/(:num)', 'Api\UmkmController::delete/$1');

    // Preflight OPTIONS routes for CORS
    $routes->options('umkm', function () {
        return '';
    });
    $routes->options('umkm/(:num)', function () {
        return '';
    });
});
