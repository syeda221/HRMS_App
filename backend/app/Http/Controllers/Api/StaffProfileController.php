<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules\Password;

class StaffProfileController extends Controller
{
    public function profile(Request $request)
    {
        $user = $request->user()->load(['department', 'designation']);

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $user->id,
                'employee_code' => $user->employee_code,
                'name' => $user->name,
                'email' => $user->email,
                'phone' => $user->phone,
                'department' => $user->department?->name ?? 'General',
                'designation' => $user->designation?->title ?? 'Staff Member',
                'joining_date' => $user->joining_date?->format('M d, Y') ?? 'N/A',
                'avatar_url' => $user->avatar_url,
                'status' => ucfirst($user->status),
                'shift_policy' => [
                    'shift_name' => 'General Day Shift',
                    'shift_hours' => '09:00 AM - 06:00 PM',
                    'start_time' => '09:00 AM',
                    'end_time' => '06:00 PM',
                    'required_daily_hours' => 8.0,
                    'grace_period_mins' => 15,
                    'late_threshold' => '09:15 AM',
                    'work_days' => 'Mon - Fri',
                    'late_rule_text' => 'Check-in after 09:15 AM is marked as Late',
                    'hours_rule_text' => 'Minimum 8.0 working hours required per day',
                ],
            ],
        ]);
    }

    public function changePassword(Request $request)
    {
        $request->validate([
            'current_password' => 'required|string',
            'new_password' => ['required', 'string', 'min:6'],
        ]);

        $user = $request->user();

        if (! Hash::check($request->current_password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'The provided current password does not match our records.',
            ], 422);
        }

        $user->update([
            'password' => Hash::make($request->new_password),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Password changed successfully.',
        ]);
    }
}
