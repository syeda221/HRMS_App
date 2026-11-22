<?php

namespace Database\Seeders;

use App\Models\Attendance;
use App\Models\Department;
use App\Models\Designation;
use App\Models\OfficeLocation;
use App\Models\Shift;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AdminDashboardSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Shifts
        $morningShift = Shift::firstOrCreate(
            ['name' => 'Morning Shift'],
            [
                'start_time' => '09:00:00',
                'end_time' => '18:00:00',
                'grace_period_mins' => 15,
                'required_hours' => 8.0,
                'working_days' => 'Mon - Fri',
                'is_active' => true,
            ]
        );

        $eveningShift = Shift::firstOrCreate(
            ['name' => 'Evening Shift'],
            [
                'start_time' => '14:00:00',
                'end_time' => '22:00:00',
                'grace_period_mins' => 15,
                'required_hours' => 8.0,
                'working_days' => 'Mon - Fri',
                'is_active' => true,
            ]
        );

        // 2. Departments & Designations
        $eng = Department::firstOrCreate(['code' => 'ENG'], ['name' => 'Engineering']);
        $des = Department::firstOrCreate(['code' => 'DES'], ['name' => 'Product Design']);
        $ops = Department::firstOrCreate(['code' => 'OPS'], ['name' => 'Operations']);
        $hr = Department::firstOrCreate(['code' => 'HR'], ['name' => 'Human Resources']);

        $leadDesig = Designation::firstOrCreate(['title' => 'Lead FullStack Engineer', 'department_id' => $eng->id]);
        $uiDesig = Designation::firstOrCreate(['title' => 'Senior UI/UX Designer', 'department_id' => $des->id]);
        $pmDesig = Designation::firstOrCreate(['title' => 'Product Manager', 'department_id' => $ops->id]);
        $hrDesig = Designation::firstOrCreate(['title' => 'HR Specialist', 'department_id' => $hr->id]);
        $adminDesig = Designation::firstOrCreate(['title' => 'System Director', 'department_id' => $ops->id]);

        // 3. Admin Account
        User::updateOrCreate(
            ['email' => 'admin@company.com'],
            [
                'employee_code' => 'ADM-001',
                'name' => 'Admin Director',
                'phone' => '+1 (555) 019-2834',
                'password' => Hash::make('admin123'),
                'role' => 'admin',
                'department_id' => $ops->id,
                'designation_id' => $adminDesig->id,
                'shift_id' => $morningShift->id,
                'joining_date' => Carbon::now()->subYears(3)->toDateString(),
                'avatar_url' => 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&q=80&w=300',
                'status' => 'active',
            ]
        );

        // 4. Update Alex Morgan with shift
        User::where('email', 'staff@company.com')->update([
            'role' => 'staff',
            'shift_id' => $morningShift->id,
        ]);

        // 5. Staff Roster (Matching Stitch Screens)
        $staffMembers = [
            [
                'name' => 'Ali Khan',
                'email' => 'ali.khan@company.com',
                'employee_code' => 'EMP-001',
                'phone' => '+1 (555) 782-9901',
                'dept_id' => $eng->id,
                'desig_id' => $leadDesig->id,
                'shift_id' => $morningShift->id,
                'avatar' => 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=300',
                'today_status' => 'present',
                'check_in' => '09:05:00',
                'check_in_note' => 'Morning Shift • Gate 01 Scanner',
            ],
            [
                'name' => 'Sara Ahmed',
                'email' => 'sara.ahmed@company.com',
                'employee_code' => 'EMP-002',
                'phone' => '+1 (555) 632-1144',
                'dept_id' => $des->id,
                'desig_id' => $uiDesig->id,
                'shift_id' => $morningShift->id,
                'avatar' => 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=300',
                'today_status' => 'present',
                'check_in' => '08:58:00',
                'check_in_note' => 'Morning Shift • Mobile QR Validated',
            ],
            [
                'name' => 'Hamza Malik',
                'email' => 'hamza.malik@company.com',
                'employee_code' => 'EMP-003',
                'phone' => '+1 (555) 441-2099',
                'dept_id' => $ops->id,
                'desig_id' => $pmDesig->id,
                'shift_id' => $morningShift->id,
                'avatar' => 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=300',
                'today_status' => 'late',
                'check_in' => '09:22:00',
                'check_in_note' => 'Morning Shift • Gate 02 NFC',
            ],
            [
                'name' => 'Zainab Tariq',
                'email' => 'zainab.tariq@company.com',
                'employee_code' => 'EMP-004',
                'phone' => '+1 (555) 890-1234',
                'dept_id' => $hr->id,
                'desig_id' => $hrDesig->id,
                'shift_id' => $eveningShift->id,
                'avatar' => 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&q=80&w=300',
                'today_status' => 'present',
                'check_in' => '13:50:00',
                'check_in_note' => 'Evening Shift • Reception Kiosk',
            ],
            [
                'name' => 'Bilal Hassan',
                'email' => 'bilal.hassan@company.com',
                'employee_code' => 'EMP-005',
                'phone' => '+1 (555) 234-5678',
                'dept_id' => $eng->id,
                'desig_id' => $leadDesig->id,
                'shift_id' => $morningShift->id,
                'avatar' => 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&q=80&w=300',
                'today_status' => 'absent',
                'check_in' => null,
                'check_in_note' => 'Reported Sick Leave',
            ],
        ];

        $today = Carbon::today()->toDateString();

        foreach ($staffMembers as $item) {
            $user = User::updateOrCreate(
                ['email' => $item['email']],
                [
                    'employee_code' => $item['employee_code'],
                    'name' => $item['name'],
                    'phone' => $item['phone'],
                    'password' => Hash::make('password123'),
                    'role' => 'staff',
                    'department_id' => $item['dept_id'],
                    'designation_id' => $item['desig_id'],
                    'shift_id' => $item['shift_id'],
                    'joining_date' => Carbon::now()->subMonths(8)->toDateString(),
                    'avatar_url' => $item['avatar'],
                    'status' => 'active',
                ]
            );

            // Seed today's check-in
            if ($item['check_in']) {
                Attendance::updateOrCreate(
                    ['user_id' => $user->id, 'date' => $today],
                    [
                        'check_in' => $item['check_in'],
                        'status' => $item['today_status'],
                        'check_in_note' => $item['check_in_note'],
                    ]
                );
            } elseif ($item['today_status'] === 'absent') {
                Attendance::updateOrCreate(
                    ['user_id' => $user->id, 'date' => $today],
                    [
                        'status' => 'absent',
                        'check_in_note' => $item['check_in_note'],
                    ]
                );
            }
        }
    }
}
