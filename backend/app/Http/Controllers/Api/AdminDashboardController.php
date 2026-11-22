<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Attendance;
use App\Models\OfficeLocation;
use App\Models\Shift;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Http\Request;

class AdminDashboardController extends Controller
{
    public function dashboard(Request $request)
    {
        $today = Carbon::today()->toDateString();

        // 1. Staff Members (excluding admin from employee counts)
        $staffUsers = User::where('role', 'staff')
            ->where('status', 'active')
            ->with(['department', 'designation', 'shift'])
            ->get();

        $totalStaff = $staffUsers->count();

        // 2. Today's Attendances
        $todayAttendances = Attendance::where('date', $today)
            ->whereIn('user_id', $staffUsers->pluck('id'))
            ->with('user.department')
            ->get();

        $presentCount = $todayAttendances->whereIn('status', ['present', 'late'])->count();
        $lateCount = $todayAttendances->where('status', 'late')->count();
        $absentCount = $todayAttendances->where('status', 'absent')->count();
        // Any staff who has no record is also considered absent / not yet arrived
        $unmarkedCount = max(0, $totalStaff - $todayAttendances->count());
        $effectiveAbsentCount = $absentCount + $unmarkedCount;

        $workforcePercent = $totalStaff > 0 ? round(($presentCount / $totalStaff) * 100, 1) : 0;
        $onTimeCount = max(0, $presentCount - $lateCount);
        $onTimeRate = $presentCount > 0 ? round(($onTimeCount / $presentCount) * 100, 1) : 100;

        // 3. Shift Breakdown
        $shifts = Shift::where('is_active', true)->get();
        $shiftBreakdown = [];

        foreach ($shifts as $shift) {
            $shiftStaffCount = $staffUsers->where('shift_id', $shift->id)->count();
            $shiftPresentCount = $todayAttendances->filter(function ($att) use ($shift) {
                return $att->user && $att->user->shift_id === $shift->id && in_array($att->status, ['present', 'late']);
            })->count();

            $shiftPercent = $shiftStaffCount > 0 ? round(($shiftPresentCount / $shiftStaffCount) * 100, 1) : 0;
            $startFormatted = Carbon::parse($shift->start_time)->format('H:i');
            $endFormatted = Carbon::parse($shift->end_time)->format('H:i');

            $shiftBreakdown[] = [
                'id' => $shift->id,
                'name' => $shift->name,
                'timing_label' => "{$shift->name} ({$startFormatted} - {$endFormatted})",
                'present_count' => $shiftPresentCount,
                'total_count' => $shiftStaffCount,
                'percent' => $shiftPercent,
            ];
        }

        // 4. Recent Check-ins Activity Stream
        $recentScans = Attendance::where('date', $today)
            ->whereNotNull('check_in')
            ->whereIn('user_id', $staffUsers->pluck('id'))
            ->with(['user.department', 'user.shift'])
            ->orderByDesc('check_in')
            ->take(10)
            ->get()
            ->map(function ($att) {
                $user = $att->user;
                $checkInTime = Carbon::parse($att->check_in);
                $isLate = $att->status === 'late';

                return [
                    'id' => $att->id,
                    'user_id' => $user->id,
                    'name' => $user->name,
                    'employee_code' => $user->employee_code,
                    'avatar_url' => $user->avatar_url,
                    'department' => $user->department?->name ?? 'General',
                    'time_formatted' => $checkInTime->format('h:i A'),
                    'status' => $att->status,
                    'status_label' => $isLate ? 'Late' : 'On-Time',
                    'note' => $att->check_in_note ?? ($user->shift ? "{$user->shift->name} • QR Scanner" : "Office QR"),
                ];
            });

        // 5. Office Location & Geofence
        $office = OfficeLocation::where('is_active', true)->first();

        return response()->json([
            'success' => true,
            'data' => [
                'terminal_name' => 'HQ Terminal 01 • Live',
                'server_date' => Carbon::now()->format('M d, Y'),
                'server_time' => Carbon::now()->format('h:i A'),
                'total_staff' => $totalStaff,
                'workforce_percent' => $workforcePercent,
                'present_today' => $presentCount,
                'on_time_count' => $onTimeCount,
                'on_time_rate' => $onTimeRate,
                'late_today' => $lateCount,
                'absent_today' => $effectiveAbsentCount,
                'shifts_count' => $shifts->count(),
                'shift_breakdown' => $shiftBreakdown,
                'recent_checkins' => $recentScans,
                'geofence' => [
                    'is_active' => $office?->is_active ?? true,
                    'radius_meters' => $office?->radius_meters ?? 50,
                    'location_name' => $office?->name ?? 'HQ Main Campus',
                ],
                'office_qr' => [
                    'secret_key' => $office?->qr_secret_key ?? 'STITCH-OFFICE-HQ-2026',
                    'name' => $office?->name ?? 'HQ Reception Kiosk',
                ],
            ],
        ]);
    }
}
