<?php

// use DB;
/** @var \Laravel\Lumen\Routing\Router $router */

/*
|--------------------------------------------------------------------------
| Application Routes
|--------------------------------------------------------------------------
|
| Here is where you can register all of the routes for an application.
| It is a breeze. Simply tell Lumen the URIs it should respond to
| and give it the Closure to call when that URI is requested.
|
*/

$router->get('/', function () use ($router) {
    return $router->app->version();
});

$router->post('/register', ['uses' => 'UserController@save']);

$router->post('/login', ['uses' => 'UserController@login']);

$router->get('/profile/{id}', ['uses' => 'UserController@getbyid']);

$router->post('/update_profile/{id}', ['uses' => 'UserController@update']);

$router->post('/post', ['uses' => 'PostController@save']);

$router->get('/post', ['uses' => 'PostController@getall']);

$router->get('/post/{id}', ['uses' => 'PostController@getbyid']);

$router->get('/my_post/{id}', ['uses' => 'PostController@getall']);

$router->post('/friends/{id}', ['uses' => 'FriendsController@save']);

$router->get('/friends/{field}/{id}', ['uses' => 'FriendsController@getAll']);

$router->delete('/friends/{fid}/{uid}', ['uses' => 'FriendsController@delete']);

$router->post('/comments', ['uses' => 'CommentsController@save']);

$router->get('/comments/{postId}', ['uses' => 'CommentsController@getAll']);

$router->get('/chat/{uid}', ['uses' => 'CommentsController@history']);

$router->get('/test', function () use ($router) {

   	try {
	     $db = \DB::connection();
        if($db->getPdo()){
            echo "Yes! Successfully connected to the DB: " . $db->getDatabaseName();
        }else{
            die("Could not find the database ".env('DB_DATABASE').". Please check your configuration.");
        }
    } catch (\Exception $e) {
        die("Could not open connection to database server ".env('DB_USERNAME').".  Please check your configuration.");
    }
});