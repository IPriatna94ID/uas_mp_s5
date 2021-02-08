<?php

namespace App\Http\Controllers;

use App\Post;
use Url;
use Image;
use Illuminate\Http\Request;

class PostController extends Controller
{
    /**
     * Create a new controller instance.
     *
     * @return void
     */
    public function __construct()
    {
        //
    }

    public function getall($id = false){
        if(!empty($id)){
            $data = Post::where('user_id', $id)->orderBy('id', 'DESC')->with('user')->get();
        }else{
            $data = Post::orderBy('id', 'DESC')->with('user')->get();            
        }
        return response($data);
    }
    public function getbyid($id){
        $data = Post::where('id', $id)->with('user')->first();
        return response ($data);
    }
    public function save(Request $request){

        $this->validate($request, [
            'user_id' => 'required',
            'text' => 'required'
        ]);

        $image_base64 = base64_decode($request->input('file'));
        $path = 'uploads/' . $request->input('file_name');
        file_put_contents($path, $image_base64);

        $model = new Post();
        $model->user_id = $request->input('user_id');
        $model->text = $request->input('text');
        $model->path = $path;
        $model->created_at = date('Y-m-d H:i:s');
        $model->save();
    
        $data = array(
            'status' => 'success',
            'message' => 'Posting berhasil',
            'data' => $model
        );

        return response($data);
    }

    public function update(Request $request, $id){
        $model = Post::where('id', $id)->first();
        $model->name = $request->input('name');
        $model->email = $request->input('email');
        $model->password = md5($request->input('password'));
        $model->save();
    
        $data = array(
            'status' => 'success',
            'message' => 'Berhasil Merubah Data',
            'data' => $model
        );
        return response($data);
    }
    
    public function delete($id){
        $data = Post::where('id',$id)->first();
        $data->delete();
    
        return response('Berhasil Menghapus Data');
    }
}