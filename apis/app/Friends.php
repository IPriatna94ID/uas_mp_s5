<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class Friends extends Model
{
   protected $table = 'friends'; 

    public function user()
    {
    	return $this->belongsTo(User::class);
    }

    public function cb()
    {
    	return $this->hasOne(User::class, 'id', 'created_by');
    }
}