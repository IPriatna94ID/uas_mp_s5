<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class User extends Model
{
   protected $table = 'users'; 

    public function posts()
    {
    	return $this->hasMany(Post::class, 'user_id', 'id');
    }

    public function followers()
    {
    	return $this->hasMany(Friends::class, 'user_id', 'id');
    }

    public function following()
    {
    	return $this->hasMany(Friends::class, 'created_by', 'id');
    }

    public function followed()
    {
    	return $this->hasOne(Friends::class, 'user_id', 'id');
    }
}