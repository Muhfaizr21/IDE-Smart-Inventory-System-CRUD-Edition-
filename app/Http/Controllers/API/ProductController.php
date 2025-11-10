<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ProductController extends Controller
{
    public function index()
    {
        $q = request('q');
        $products = Product::when($q, fn($query) => $query->where('name','like',"%{$q}%"))
                    ->orderBy('created_at','desc')
                    ->paginate(15);
        return response()->json($products);
    }

    public function store(Request $req)
    {
        $data = $req->validate([
            'name'=>'required|string|max:255',
            'description'=>'nullable|string',
            'stock'=>'required|integer|min:0',
            'price'=>'required|numeric|min:0',
            'category'=>'nullable|string|max:100',
            'image'=>'nullable|image|max:2048',
        ]);

        if ($req->hasFile('image')) {
            $path = $req->file('image')->store('products','public');
            $data['image'] = $path;
        }

        $product = Product::create($data);
        return response()->json($product, 201);
    }

    public function show(Product $product)
    {
        return response()->json($product);
    }

    public function update(Request $req, Product $product)
    {
        $data = $req->validate([
            'name'=>'required|string|max:255',
            'description'=>'nullable|string',
            'stock'=>'required|integer|min:0',
            'price'=>'required|numeric|min:0',
            'category'=>'nullable|string|max:100',
            'image'=>'nullable|image|max:2048',
        ]);

        if ($req->hasFile('image')) {
            if ($product->image) Storage::disk('public')->delete($product->image);
            $path = $req->file('image')->store('products','public');
            $data['image'] = $path;
        }

        $product->update($data);
        return response()->json($product);
    }

    public function destroy(Product $product)
    {
        if ($product->image) Storage::disk('public')->delete($product->image);
        $product->delete();
        return response()->json(['message'=>'Deleted']);
    }
}
