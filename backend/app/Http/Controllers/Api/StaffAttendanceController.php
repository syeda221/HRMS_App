<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Attendance;
use App\Models\Holiday;
use App\Models\OfficeLocation;
use Carbon\Carbon;
use Illuminate\Http\Request;

class StaffAttendanceController extends Controller
{
    /**
     * Dashboard Overview
     */
    public function dashboard(Request $request)
    {
        $user = $request->user();
        $today = Carbon::today()->toDateString();
        $startOfMonth = Carbon::now()->startOfMonth()->toDateString();
        $endOfMonth = Carbon::now()->endOfMonth()->toDateString();

        // 1. Today's Record
        $todayRecord = Attendance::where('user_id', $user->id)
            ->where('date', $today)
            ->first();

        $todayStatus = 'not_marked';
        if ($todayRecord) {
            if ($todayRecord->check_out) {
                $todayStatus = 'checked_out';
            } elseif ($todayRecord->check_in) {
                $todayStatus = 'checked_in';
            } else {
                $todayStatus = $todayRecord->status;
            }
        }

        // 2. Month-to-date Metrics
        $monthRecords = Attendance::where('user_id', $user->id)
            ->whereBetween('date', [$startOfMonth, $endOfMonth])
            ->get();

        $presentDays = $monthRecords->whereIn('status', ['present', 'late'])->count();
        $lateDays = $monthRecords->where('status', 'late')->count();
        $absentDays = $monthRecords->where('status', 'absent')->count();
        $holidaysCount = $monthRecords->where('status', 'holiday')->count();
        $totalHours = round($monthRecords->sum('total_hours'), 1);

        return response()->json([
            'success' => true,
            'data' => [
                'server_time' => Carbon::now()->format('h:i A'),
                'server_date' => Carbon::now()->format('l, d M Y'),
                'today' => [
                    'date' => $today,
                    'status' => $todayStatus,
                    'attendance_badge' => $todayRecord?->status ?? 'Not Checked In',
                    'check_in' => $todayRecord?->check_in ? Carbon::parse($todayRecord->check_in)->format('h:i A') : null,
                    'check_out' => $todayRecord?->check_out ? Carbon::parse($todayRecord->check_out)->format('h:i A') : null,
                    'total_hours' => $todayRecord?->total_hours ?? 0,
                    'can_check_in' => ! $todayRecord || ! $todayRecord->check_in,
                    'can_check_out' => $todayRecord && $todayRecord->check_in && ! $todayRecord->check_out,
                ],
                'monthly_summary' => [
                    'present_days' => $presentDays,
                    'late_days' => $lateDays,
                    'absent_days' => $absentDays,
                    'holidays' => $holidaysCount,
                    'total_hours' => $totalHours,
                ],
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

    /**
     * QR Code Scan (Check In / Check Out)
     */
    public function scan(Request $request)
    {
        $request->validate([
            'qr_token' => 'required|string',
            'note' => 'nullable|string',
        ]);

        $user = $request->user();
        $qrToken = trim($request->input('qr_token'));

        // Validate office location QR
        $office = OfficeLocation::where('qr_secret_key', $qrToken)
            ->where('is_active', true)
            ->first();

        if (! $office) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid or unrecognized office QR code.',
            ], 422);
        }

        $now = Carbon::now();
        $today = $now->toDateString();
        $timeStr = $now->format('H:i:s');

        $record = Attendance::where('user_id', $user->id)
            ->where('date', $today)
            ->first();

        if (! $record || ! $record->check_in) {
            // Check-In
            // Standard time 09:00:00. If after 09:15:00, marked as 'late' (15-min grace)
            $status = ($now->hour > 9 || ($now->hour == 9 && $now->minute > 15)) ? 'late' : 'present';

            $record = Attendance::updateOrCreate(
                ['user_id' => $user->id, 'date' => $today],
                [
                    'check_in' => $timeStr,
                    'status' => $status,
                    'check_in_note' => $request->note ?? "QR Check-in at {$office->name}",
                ]
            );

            return response()->json([
                'success' => true,
                'type' => 'check_in',
                'message' => 'Check-in recorded successfully at ' . $now->format('h:i A') . '.',
                'data' => [
                    'status' => $status,
                    'check_in' => $now->format('h:i A'),
                    'check_out' => null,
                    'total_hours' => 0,
                ],
            ]);
        }

        if ($record->check_in && ! $record->check_out) {
            // Check-Out
            $checkInCarbon = Carbon::parse("{$today} {$record->check_in}");
            $hours = abs(round($now->diffInMinutes($checkInCarbon) / 60, 2));

            $record->update([
                'check_out' => $timeStr,
                'total_hours' => $hours,
                'check_out_note' => $request->note ?? "QR Check-out at {$office->name}",
            ]);

            return response()->json([
                'success' => true,
                'type' => 'check_out',
                'message' => 'Check-out recorded successfully at ' . $now->format('h:i A') . ". Total: {$hours} hrs.",
                'data' => [
                    'status' => $record->status,
                    'check_in' => Carbon::parse($record->check_in)->format('h:i A'),
                    'check_out' => $now->format('h:i A'),
                    'total_hours' => $hours,
                ],
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => 'You have already completed check-in and check-out for today.',
        ], 400);
    }

    /**
     * Monthly Calendar View
     */
    public function calendar(Request $request)
    {
        $user = $request->user();
        $monthInput = $request->query('month', Carbon::now()->format('Y-m'));

        $start = Carbon::parse($monthInput . '-01')->startOfMonth();
        $end = $start->copy()->endOfMonth();

        $records = Attendance::where('user_id', $user->id)
            ->whereBetween('date', [$start->toDateString(), $end->toDateString()])
            ->get()
            ->keyBy(fn ($item) => Carbon::parse($item->date)->toDateString());

        $days = [];
        $current = $start->copy();

        while ($current->lte($end)) {
            $dateStr = $current->toDateString();
            $att = $records->get($dateStr);

            $days[] = [
                'date' => $dateStr,
                'day_number' => $current->day,
                'day_name' => $current->format('D'),
                'is_weekend' => $current->isWeekend(),
                'status' => $att?->status ?? ($current->isWeekend() ? 'holiday' : 'not_marked'),
                'check_in' => $att?->check_in ? Carbon::parse($att->check_in)->format('h:i A') : null,
                'check_out' => $att?->check_out ? Carbon::parse($att->check_out)->format('h:i A') : null,
                'total_hours' => $att?->total_hours ?? 0,
                'note' => $att?->check_in_note,
            ];

            $current->addDay();
        }

        return response()->json([
            'success' => true,
            'data' => [
                'month' => $monthInput,
                'month_name' => $start->format('F Y'),
                'days' => $days,
            ],
        ]);
    }

    /**
     * Attendance History Feed
     */
    public function history(Request $request)
    {
        $user = $request->user();

        $history = Attendance::where('user_id', $user->id)
            ->orderBy('date', 'desc')
            ->paginate(15);

        $mapped = $history->getCollection()->map(function ($item) {
            $dateCarbon = Carbon::parse($item->date);
            return [
                'id' => $item->id,
                'date' => $dateCarbon->format('Y-m-d'),
                'formatted_date' => $dateCarbon->format('d M, Y'),
                'day_name' => $dateCarbon->format('l'),
                'status' => $item->status,
                'check_in' => $item->check_in ? Carbon::parse($item->check_in)->format('h:i A') : '--:--',
                'check_out' => $item->check_out ? Carbon::parse($item->check_out)->format('h:i A') : '--:--',
                'total_hours' => $item->total_hours ? number_format($item->total_hours, 1) . ' hrs' : '-',
                'note' => $item->check_in_note ?? $item->check_out_note,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $mapped,
            'meta' => [
                'current_page' => $history->currentPage(),
                'last_page' => $history->lastPage(),
                'total' => $history->total(),
            ],
        ]);
    }

    /**
     * Monthly Report & Analytics
     */
    public function report(Request $request)
    {
        $user = $request->user();
        $monthInput = $request->query('month', Carbon::now()->format('Y-m'));

        $start = Carbon::parse($monthInput . '-01')->startOfMonth();
        $end = $start->copy()->endOfMonth();

        $records = Attendance::where('user_id', $user->id)
            ->whereBetween('date', [$start->toDateString(), $end->toDateString()])
            ->get();

        $presentCount = $records->where('status', 'present')->count();
        $lateCount = $records->where('status', 'late')->count();
        $absentCount = $records->where('status', 'absent')->count();
        $holidayCount = $records->where('status', 'holiday')->count();
        $totalHours = round($records->sum('total_hours'), 1);

        $totalWorkingDays = $presentCount + $lateCount + $absentCount;
        $attendanceRate = $totalWorkingDays > 0
            ? round((($presentCount + $lateCount) / $totalWorkingDays) * 100, 1)
            : 100.0;

        return response()->json([
            'success' => true,
            'data' => [
                'month' => $monthInput,
                'month_name' => $start->format('F Y'),
                'attendance_rate' => $attendanceRate,
                'present_days' => $presentCount,
                'late_days' => $lateCount,
                'absent_days' => $absentCount,
                'holidays' => $holidayCount,
                'total_hours' => $totalHours,
                'average_hours_per_day' => ($presentCount + $lateCount) > 0 ? round($totalHours / ($presentCount + $lateCount), 1) : 0,
            ],
        ]);
    }
}
