<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Payroll;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AdminPayrollController extends Controller
{
    /**
     * Get monthly payroll overview & employee salaries
     */
    public function index(Request $request): JsonResponse
    {
        $month = $request->query('month', Carbon::today()->format('Y-m'));

        $payrolls = Payroll::with('user.department', 'user.designation')
            ->where('month', $month)
            ->get();

        // If no records exist yet for this month, auto-generate from active staff
        if ($payrolls->isEmpty()) {
            $this->generateMonthlyRecords($month);
            $payrolls = Payroll::with('user.department', 'user.designation')
                ->where('month', $month)
                ->get();
        }

        $totalDisbursed = $payrolls->where('status', 'paid')->sum('net_salary');
        $totalPending = $payrolls->where('status', 'pending')->sum('net_salary');
        $totalDeductions = $payrolls->sum('deductions');
        $totalBasic = $payrolls->sum('basic_salary');

        $salaryList = $payrolls->map(function ($p) {
            $u = $p->user;
            return [
                'id' => $p->id,
                'user_id' => $p->user_id,
                'employee_code' => $u ? $u->employee_code : 'EMP-000',
                'name' => $u ? $u->name : 'Unknown Staff',
                'avatar_url' => $u ? $u->avatar_url : '',
                'department' => $u && $u->department ? $u->department->name : 'Engineering',
                'designation' => $u && $u->designation ? $u->designation->title : 'Staff',
                'month' => $p->month,
                'basic_salary' => (float) $p->basic_salary,
                'allowances' => (float) $p->allowances,
                'deductions' => (float) $p->deductions,
                'net_salary' => (float) $p->net_salary,
                'present_days' => $p->present_days,
                'late_days' => $p->late_days,
                'absent_days' => $p->absent_days,
                'status' => $p->status,
                'payment_date' => $p->payment_date ? Carbon::parse($p->payment_date)->format('M d, Y') : null,
                'payment_method' => $p->payment_method,
                'notes' => $p->notes,
            ];
        });

        return response()->json([
            'status' => true,
            'message' => 'Payroll records retrieved successfully.',
            'data' => [
                'month' => $month,
                'summary' => [
                    'total_payroll' => (float) ($totalDisbursed + $totalPending),
                    'total_disbursed' => (float) $totalDisbursed,
                    'total_pending' => (float) $totalPending,
                    'total_deductions' => (float) $totalDeductions,
                    'paid_count' => $payrolls->where('status', 'paid')->count(),
                    'pending_count' => $payrolls->where('status', 'pending')->count(),
                ],
                'payrolls' => $salaryList,
            ],
        ]);
    }

    /**
     * Run / Recalculate Payroll for month
     */
    public function generate(Request $request): JsonResponse
    {
        $month = $request->input('month', Carbon::today()->format('Y-m'));
        $this->generateMonthlyRecords($month);

        return response()->json([
            'status' => true,
            'message' => "Payroll for month {$month} successfully generated and recalculated.",
        ]);
    }

    /**
     * Update payment status (e.g. mark Paid)
     */
    public function updateStatus(Request $request, int $id): JsonResponse
    {
        $payroll = Payroll::findOrFail($id);

        $validated = $request->validate([
            'status' => 'required|in:paid,pending,processing',
            'payment_method' => 'nullable|string',
            'notes' => 'nullable|string',
        ]);

        $payroll->update([
            'status' => $validated['status'],
            'payment_date' => $validated['status'] === 'paid' ? Carbon::today()->toDateString() : null,
            'payment_method' => $validated['payment_method'] ?? $payroll->payment_method,
            'notes' => $validated['notes'] ?? $payroll->notes,
        ]);

        return response()->json([
            'status' => true,
            'message' => 'Payroll status updated.',
            'data' => $payroll,
        ]);
    }

    private function generateMonthlyRecords(string $month): void
    {
        $staff = User::where('role', 'staff')->where('status', 'active')->get();

        foreach ($staff as $u) {
            $basic = (float) $u->basic_salary;
            $allowance = round($basic * 0.15, 2);
            $deductions = 0.00;
            $net = $basic + $allowance - $deductions;

            Payroll::updateOrCreate(
                ['user_id' => $u->id, 'month' => $month],
                [
                    'basic_salary' => $basic,
                    'allowances' => $allowance,
                    'deductions' => $deductions,
                    'net_salary' => $net,
                    'present_days' => 22,
                    'late_days' => 0,
                    'absent_days' => 0,
                    'status' => 'pending',
                    'payment_method' => 'Direct Bank Transfer',
                ]
            );
        }
    }
}
