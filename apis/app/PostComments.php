<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class PostComments extends Model
{
   protected $table = 'post_comments'; 

    public function post()
    {
    	return $this->belongsTo(Post::class);
    }

    public function user()
    {
    	return $this->belongsTo(User::class);
    }

    public function cb()
    {
    	return $this->hasOne(User::class, 'id', 'created_by');
    }
}