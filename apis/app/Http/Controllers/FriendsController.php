<?php

namespace App\Http\Controllers;

use App\Friends;
use Illuminate\Http\Request;

class FriendsController extends Controller
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

    public function getall($field, $id){
        $data = Friends::where($field, $id)->orderBy('id', 'DESC')->with('user', 'cb')->withCount('followed')->get();
        return response($data);
    }
    public function getbyid($id){
        $data = Friends::where('id',$id)->first();
        return response ($data);
    }
    public function save(Request $request, $id){

        $this->validate($request, [
            'user_id' => 'required'
        ]);


        $model = Friends::where('user_id', $request->input('user_id'))->first();

        if(empty($model)){
            $model = new Friends();
            $model->user_id = $request->input('user_id');
            $model->created_by = $id;
            $model->save();
        }
    
        $data = array(
            'status' => 'success',
            'message' => 'Berhasil Menambah Data',
            'data' => $model
        );
        return response($data);
    }

    public function update(Request $request, $id){
        $model = Friends::where('id', $id)->first();
        $model->save();    
        $data = array(
            'status' => 'success',
            'message' => 'Berhasil Merubah Data',
            'data' => $model
        );
        return response($data);
    }
    
    public function delete($fid, $uid){
        $model = Friends::where('user_id', $fid)->where('created_by', $uid)->first();
        $model->delete();
            $data = array(
            'status' => 'success',
            'message' => 'Berhasil Menghapus Data'
        );
        return response($data);
    }
}