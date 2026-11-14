<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class StaffAuthController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'login' => 'required|string', // email or employee_code
            'password' => 'required|string',
        ]);

        $login = $request->input('login');

        $user = User::with(['department', 'designation'])
            ->where('email', $login)
            ->orWhere('employee_code', $login)
            ->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid credentials. Please verify your email / employee ID and password.',
            ], 401);
        }

        if ($user->status !== 'active') {
            return response()->json([
                'success' => false,
                'message' => 'Your staff account is currently deactivated. Please contact HR.',
            ], 403);
        }

        // Revoke previous tokens if any for clean single-session or create fresh
        $token = $user->createToken('staff-mobile-app')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Signed in successfully.',
            'data' => [
                'token' => $token,
                'user' => [
                    'id' => $user->id,
                    'employee_code' => $user->employee_code,
                    'name' => $user->name,
                    'email' => $user->email,
                    'phone' => $user->phone,
                    'department' => $user->department?->name ?? 'General',
                    'designation' => $user->designation?->title ?? 'Staff Member',
                    'joining_date' => $user->joining_date?->format('Y-m-d'),
                    'avatar_url' => $user->avatar_url,
                ],
            ],
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Signed out successfully.',
        ]);
    }
}
