<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Department;
use App\Models\Designation;
use App\Models\Shift;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class AdminStaffController extends Controller
{
    /**
     * Get list of employees with search and department filtering.
     */
    public function index(Request $request): JsonResponse
    {
        $query = User::with(['department', 'designation', 'shift'])
            ->where('role', 'staff');

        if ($request->filled('search')) {
            $search = $request->query('search');
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                    ->orWhere('employee_code', 'like', "%{$search}%")
                    ->orWhere('email', 'like', "%{$search}%");
            });
        }

        if ($request->filled('department_id')) {
            $query->where('department_id', $request->query('department_id'));
        }

        if ($request->filled('status')) {
            $query->where('status', $request->query('status'));
        }

        $employees = $query->orderBy('name')->get();
        $today = Carbon::today()->toDateString();

        $employeeList = $employees->map(function ($emp) use ($today) {
            $todayAttendance = $emp->attendances()
                ->where('date', $today)
                ->first();

            return [
                'id' => $emp->id,
                'employee_code' => $emp->employee_code ?? 'EMP-' . str_pad($emp->id, 3, '0', STR_PAD_LEFT),
                'name' => $emp->name,
                'email' => $emp->email,
                'phone' => $emp->phone ?? '',
                'emergency_contact' => $emp->emergency_contact ?? '',
                'avatar_url' => $emp->avatar_url ?? '',
                'department' => $emp->department ? [
                    'id' => $emp->department->id,
                    'name' => $emp->department->name,
                    'code' => $emp->department->code,
                ] : null,
                'designation' => $emp->designation ? [
                    'id' => $emp->designation->id,
                    'title' => $emp->designation->title,
                ] : null,
                'shift' => $emp->shift ? [
                    'id' => $emp->shift->id,
                    'name' => $emp->shift->name,
                    'start_time' => substr($emp->shift->start_time, 0, 5),
                    'end_time' => substr($emp->shift->end_time, 0, 5),
                    'grace_period_mins' => $emp->shift->grace_period_mins,
                ] : null,
                'basic_salary' => (float) $emp->basic_salary,
                'status' => $emp->status,
                'joining_date' => $emp->joining_date ? Carbon::parse($emp->joining_date)->format('Y-m-d') : null,
                'today_status' => $todayAttendance ? $todayAttendance->status : 'absent',
                'today_check_in' => $todayAttendance && $todayAttendance->check_in ? substr($todayAttendance->check_in, 0, 5) : null,
            ];
        });

        // Meta data for dropdowns (departments, shifts, designations)
        $departments = Department::select('id', 'name', 'code')->get();
        $shifts = Shift::where('is_active', true)->select('id', 'name', 'start_time', 'end_time', 'grace_period_mins')->get();
        $designations = Designation::select('id', 'title', 'department_id')->get();

        return response()->json([
            'status' => true,
            'message' => 'Staff directory retrieved successfully.',
            'data' => [
                'total_staff' => $employeeList->count(),
                'active_count' => $employeeList->where('status', 'active')->count(),
                'employees' => $employeeList,
                'departments' => $departments,
                'shifts' => $shifts,
                'designations' => $designations,
            ],
        ]);
    }

    /**
     * Store new employee
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'phone' => 'nullable|string',
            'emergency_contact' => 'nullable|string',
            'department_id' => 'nullable|exists:departments,id',
            'designation_id' => 'nullable|exists:designations,id',
            'shift_id' => 'nullable|exists:shifts,id',
            'basic_salary' => 'nullable|numeric|min:0',
            'joining_date' => 'nullable|date',
            'password' => 'nullable|string|min:6',
        ]);

        $nextId = (User::max('id') ?? 0) + 1;
        $employeeCode = 'EMP-' . str_pad($nextId, 3, '0', STR_PAD_LEFT);

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password'] ?? 'password123'),
            'employee_code' => $employeeCode,
            'phone' => $validated['phone'] ?? null,
            'emergency_contact' => $validated['emergency_contact'] ?? null,
            'department_id' => $validated['department_id'] ?? null,
            'designation_id' => $validated['designation_id'] ?? null,
            'shift_id' => $validated['shift_id'] ?? null,
            'basic_salary' => $validated['basic_salary'] ?? 50000.00,
            'joining_date' => $validated['joining_date'] ?? Carbon::today()->toDateString(),
            'role' => 'staff',
            'status' => 'active',
            'avatar_url' => 'https://ui-avatars.com/api/?name=' . urlencode($validated['name']) . '&background=063B2B&color=B8E83D&bold=true',
        ]);

        return response()->json([
            'status' => true,
            'message' => 'Staff member registered successfully.',
            'data' => $user->load(['department', 'designation', 'shift']),
        ], 201);
    }

    /**
     * Get single employee detail / digital badge
     */
    public function show(int $id): JsonResponse
    {
        $user = User::with(['department', 'designation', 'shift', 'attendances' => function ($q) {
            $q->orderBy('date', 'desc')->limit(10);
        }, 'payrolls' => function ($q) {
            $q->orderBy('month', 'desc')->limit(6);
        }])->findOrFail($id);

        $qrBadgePayload = json_encode([
            'app' => 'HRMS-ATTENDANCE',
            'type' => 'EMPLOYEE_BADGE',
            'employee_code' => $user->employee_code,
            'id' => $user->id,
            'name' => $user->name,
            'role' => $user->role,
            'shift' => $user->shift ? $user->shift->name : 'Standard Shift',
            'created' => Carbon::now()->toIso8601String(),
        ]);

        return response()->json([
            'status' => true,
            'message' => 'Staff details retrieved.',
            'data' => [
                'employee' => $user,
                'qr_badge_payload' => $qrBadgePayload,
            ],
        ]);
    }

    /**
     * Update employee
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $user = User::findOrFail($id);

        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'phone' => 'nullable|string',
            'emergency_contact' => 'nullable|string',
            'department_id' => 'nullable|exists:departments,id',
            'designation_id' => 'nullable|exists:designations,id',
            'shift_id' => 'nullable|exists:shifts,id',
            'basic_salary' => 'nullable|numeric|min:0',
            'status' => 'nullable|in:active,inactive',
        ]);

        $user->update($validated);

        return response()->json([
            'status' => true,
            'message' => 'Employee updated successfully.',
            'data' => $user->load(['department', 'designation', 'shift']),
        ]);
    }
}
