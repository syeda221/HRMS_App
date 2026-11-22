<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Attendance;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AdminAttendanceController extends Controller
{
    /**
     * Get all staff attendance for a given date with status filter
     */
    public function index(Request $request): JsonResponse
    {
        $date = $request->query('date', Carbon::today()->toDateString());
        $statusFilter = $request->query('status', 'all'); // all, present, late, absent

        $staffUsers = User::with(['department', 'designation', 'shift'])
            ->where('role', 'staff')
            ->where('status', 'active')
            ->orderBy('name')
            ->get();

        $attendances = Attendance::with('overriddenBy')
            ->where('date', $date)
            ->get()
            ->keyBy('user_id');

        $rows = [];
        $presentCount = 0;
        $lateCount = 0;
        $absentCount = 0;

        foreach ($staffUsers as $emp) {
            $att = $attendances->get($emp->id);
            $status = $att ? $att->status : 'absent';

            if ($status === 'present') {
                $presentCount++;
            } elseif ($status === 'late') {
                $lateCount++;
            } else {
                $absentCount++;
            }

            // Apply filter
            if ($statusFilter !== 'all' && $status !== $statusFilter) {
                continue;
            }

            $rows[] = [
                'user_id' => $emp->id,
                'employee_code' => $emp->employee_code,
                'name' => $emp->name,
                'email' => $emp->email,
                'avatar_url' => $emp->avatar_url,
                'department' => $emp->department ? $emp->department->name : 'General',
                'designation' => $emp->designation ? $emp->designation->title : 'Staff Member',
                'shift_name' => $emp->shift ? $emp->shift->name : 'Standard Shift',
                'shift_timing' => $emp->shift ? substr($emp->shift->start_time, 0, 5) . ' - ' . substr($emp->shift->end_time, 0, 5) : '09:00 - 18:00',
                'attendance_id' => $att ? $att->id : null,
                'date' => $date,
                'status' => $status,
                'check_in' => $att && $att->check_in ? substr($att->check_in, 0, 5) : '--:--',
                'check_out' => $att && $att->check_out ? substr($att->check_out, 0, 5) : '--:--',
                'total_hours' => $att && $att->total_hours ? (float) $att->total_hours : 0.0,
                'is_manual_override' => $att ? (bool) $att->is_manual_override : false,
                'note' => $att ? $att->check_in_note : null,
            ];
        }

        $totalStaff = $staffUsers->count();
        $onTimePercent = $totalStaff > 0 ? round(($presentCount / $totalStaff) * 100, 1) : 0;

        return response()->json([
            'status' => true,
            'message' => 'Attendance monitor records retrieved.',
            'data' => [
                'date' => $date,
                'metrics' => [
                    'total_staff' => $totalStaff,
                    'present_count' => $presentCount,
                    'late_count' => $lateCount,
                    'absent_count' => $absentCount,
                    'on_time_rate' => $onTimePercent,
                ],
                'records' => $rows,
            ],
        ]);
    }

    /**
     * Manual Override / Admin Correction
     */
    public function override(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'user_id' => 'required|exists:users,id',
            'date' => 'required|date',
            'status' => 'required|in:present,late,absent,half_day',
            'check_in' => 'nullable|string',
            'check_out' => 'nullable|string',
            'note' => 'nullable|string',
        ]);

        $checkIn = $validated['check_in'] ? (strlen($validated['check_in']) === 5 ? $validated['check_in'] . ':00' : $validated['check_in']) : null;
        $checkOut = $validated['check_out'] ? (strlen($validated['check_out']) === 5 ? $validated['check_out'] . ':00' : $validated['check_out']) : null;

        $hours = null;
        if ($checkIn && $checkOut) {
            $cIn = Carbon::createFromFormat('H:i:s', $checkIn);
            $cOut = Carbon::createFromFormat('H:i:s', $checkOut);
            $hours = round($cOut->diffInMinutes($cIn) / 60, 2);
        } elseif ($validated['status'] === 'present') {
            $hours = 8.0;
        }

        $adminId = $request->user() ? $request->user()->id : null;

        $attendance = Attendance::updateOrCreate(
            ['user_id' => $validated['user_id'], 'date' => $validated['date']],
            [
                'status' => $validated['status'],
                'check_in' => $checkIn,
                'check_out' => $checkOut,
                'total_hours' => $hours,
                'is_manual_override' => true,
                'overridden_by' => $adminId,
                'check_in_note' => $validated['note'] ?? 'Admin Manual Correction',
            ]
        );

        return response()->json([
            'status' => true,
            'message' => 'Attendance status manually corrected successfully.',
            'data' => $attendance,
        ]);
    }
}
