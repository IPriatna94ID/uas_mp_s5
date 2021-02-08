<?php

namespace App\Http\Controllers;

use App\PostComments;
use Url;
use Image;
use Illuminate\Http\Request;

class CommentsController extends Controller
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

    public function getall($postId = false){
        if(!empty($id)){
            $data = PostComments::where('user_id', $id)->orderBy('id', 'ASC')->with('user', 'cb')->get();
        }else{
            $data = PostComments::orderBy('id', 'ASC')->with('user', 'cb')->get();            
        }
        return response($data);
    }
    public function getbyid($id){
        $data = PostComments::where('id', $id)->with('user')->first();
        return response ($data);
    }
    public function save(Request $request){

        $this->validate($request, [
            'post_id' => 'required',
            'user_id' => 'required',
            'text' => 'required'
        ]);

        $model = new PostComments();
        $model->post_id = $request->input('post_id');
        $model->user_id = $request->input('user_id');
        $model->text = $request->input('text');
        $model->created_at = date('Y-m-d H:i:s');
        $model->created_by = $request->input('user_id');
        $model->save();
    
        $data = array(
            'status' => 'success',
            'message' => 'PostCommentsing berhasil',
            'data' => $model
        );

        return response($data);
    }

    public function update(Request $request, $id){
        $model = PostComments::where('id', $id)->first();
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
        $data = PostComments::where('id',$id)->first();
        $data->delete();
    
        return response('Berhasil Menghapus Data');
    }
}