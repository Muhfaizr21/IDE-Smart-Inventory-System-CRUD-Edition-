<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function register(Request $req)
    {
        $data = $req->validate([
            'name'=>'required|string',
            'email'=>'required|email|unique:users,email',
            'password'=>'required|min:6|confirmed'
        ]);

        $user = User::create([
            'name'=>$data['name'],
            'email'=>$data['email'],
            'password'=>Hash::make($data['password']),
        ]);

        $token = $user->createToken('mobile-token')->plainTextToken;

        return response()->json(['user'=>$user,'token'=>$token], 201);
    }

    public function login(Request $req)
    {
        $req->validate(['email'=>'required|email','password'=>'required']);

        $user = User::where('email',$req->email)->first();
        if (! $user || ! Hash::check($req->password, $user->password)) {
            throw ValidationException::withMessages(['email' => ['The provided credentials are incorrect.']]);
        }

        // revoke previous tokens (opsional)
        $user->tokens()->delete();

        $token = $user->createToken('mobile-token')->plainTextToken;
        return response()->json(['user'=>$user,'token'=>$token], 200);
    }

    public function logout(Request $req)
    {
        $req->user()->currentAccessToken()->delete();
        return response()->json(['message'=>'Logged out'], 200);
    }
}
