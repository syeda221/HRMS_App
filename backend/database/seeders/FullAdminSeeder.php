<?php

namespace Database\Seeders;

use App\Models\Attendance;
use App\Models\Department;
use App\Models\Designation;
use App\Models\OfficeLocation;
use App\Models\Payroll;
use App\Models\Shift;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class FullAdminSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Departments
        $deptEng = Department::firstOrCreate(['code' => 'ENG'], ['name' => 'Engineering & Tech']);
        $deptDesign = Department::firstOrCreate(['code' => 'DES'], ['name' => 'UI/UX & Product Design']);
        $deptOps = Department::firstOrCreate(['code' => 'OPS'], ['name' => 'Operations & HR']);
        $deptSales = Department::firstOrCreate(['code' => 'SLS'], ['name' => 'Growth & Marketing']);

        // 2. Designations
        $desLeadDev = Designation::firstOrCreate(['title' => 'Senior Flutter Engineer', 'department_id' => $deptEng->id]);
        $desBackend = Designation::firstOrCreate(['title' => 'Backend API Architect', 'department_id' => $deptEng->id]);
        $desProductDesigner = Designation::firstOrCreate(['title' => 'Lead Product Designer', 'department_id' => $deptDesign->id]);
        $desHrManager = Designation::firstOrCreate(['title' => 'HR Operations Lead', 'department_id' => $deptOps->id]);
        $desMarketingLead = Designation::firstOrCreate(['title' => 'Growth Strategist', 'department_id' => $deptSales->id]);

        // 3. Shifts
        $shiftMorning = Shift::updateOrCreate(
            ['name' => 'Morning Core Shift'],
            [
                'start_time' => '09:00:00',
                'end_time' => '18:00:00',
                'grace_period_mins' => 15,
                'required_hours' => 8.0,
                'working_days' => 'Mon - Fri',
                'is_active' => true,
            ]
        );

        $shiftEvening = Shift::updateOrCreate(
            ['name' => 'Evening Development Shift'],
            [
                'start_time' => '14:00:00',
                'end_time' => '22:00:00',
                'grace_period_mins' => 15,
                'required_hours' => 8.0,
                'working_days' => 'Mon - Fri',
                'is_active' => true,
            ]
        );

        $shiftNight = Shift::updateOrCreate(
            ['name' => 'Global Support Night Shift'],
            [
                'start_time' => '22:00:00',
                'end_time' => '06:00:00',
                'grace_period_mins' => 10,
                'required_hours' => 8.0,
                'working_days' => 'Sun - Thu',
                'is_active' => true,
            ]
        );

        $shiftRemote = Shift::updateOrCreate(
            ['name' => 'Flexible Remote Shift'],
            [
                'start_time' => '10:00:00',
                'end_time' => '19:00:00',
                'grace_period_mins' => 30,
                'required_hours' => 8.0,
                'working_days' => 'Mon - Fri',
                'is_active' => true,
            ]
        );

        // 4. Admin User
        $admin = User::updateOrCreate(
            ['email' => 'admin@company.com'],
            [
                'employee_code' => 'ADM-001',
                'name' => 'Alexander Vance',
                'phone' => '+92 300 1234567',
                'emergency_contact' => '+92 321 7654321',
                'password' => Hash::make('admin123'),
                'department_id' => $deptOps->id,
                'designation_id' => $desHrManager->id,
                'shift_id' => $shiftMorning->id,
                'basic_salary' => 180000.00,
                'role' => 'admin',
                'status' => 'active',
                'joining_date' => '2023-01-15',
                'avatar_url' => 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop',
            ]
        );

        // 5. Staff Users
        $staffMembers = [
            [
                'code' => 'EMP-001',
                'name' => 'Ali Khan',
                'email' => 'ali.khan@company.com',
                'phone' => '+92 300 2345678',
                'emergency_contact' => '+92 311 9876543',
                'dept' => $deptEng->id,
                'desig' => $desLeadDev->id,
                'shift' => $shiftMorning->id,
                'salary' => 135000.00,
                'joining' => '2023-06-01',
                'avatar' => 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&auto=format&fit=crop',
                'status' => 'active',
            ],
            [
                'code' => 'EMP-002',
                'name' => 'Sara Ahmed',
                'email' => 'sara.ahmed@company.com',
                'phone' => '+92 301 3456789',
                'emergency_contact' => '+92 322 8765432',
                'dept' => $deptDesign->id,
                'desig' => $desProductDesigner->id,
                'shift' => $shiftMorning->id,
                'salary' => 125000.00,
                'joining' => '2023-08-15',
                'avatar' => 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&auto=format&fit=crop',
                'status' => 'active',
            ],
            [
                'code' => 'EMP-003',
                'name' => 'Hamza Malik',
                'email' => 'hamza.malik@company.com',
                'phone' => '+92 302 4567890',
                'emergency_contact' => '+92 333 7654321',
                'dept' => $deptEng->id,
                'desig' => $desBackend->id,
                'shift' => $shiftMorning->id,
                'salary' => 110000.00,
                'joining' => '2024-01-10',
                'avatar' => 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&auto=format&fit=crop',
                'status' => 'active',
            ],
            [
                'code' => 'EMP-004',
                'name' => 'Zainab Tariq',
                'email' => 'zainab.tariq@company.com',
                'phone' => '+92 303 5678901',
                'emergency_contact' => '+92 344 6543210',
                'dept' => $deptSales->id,
                'desig' => $desMarketingLead->id,
                'shift' => $shiftEvening->id,
                'salary' => 95000.00,
                'joining' => '2024-03-01',
                'avatar' => 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=200&auto=format&fit=crop',
                'status' => 'active',
            ],
            [
                'code' => 'EMP-005',
                'name' => 'Bilal Hassan',
                'email' => 'bilal.hassan@company.com',
                'phone' => '+92 304 6789012',
                'emergency_contact' => '+92 355 5432109',
                'dept' => $deptOps->id,
                'desig' => $desHrManager->id,
                'shift' => $shiftRemote->id,
                'salary' => 85000.00,
                'joining' => '2024-05-20',
                'avatar' => 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=200&auto=format&fit=crop',
                'status' => 'active',
            ],
            [
                'code' => 'EMP-006',
                'name' => 'Ayesha Siddiqui',
                'email' => 'staff@company.com', // Demo default staff
                'phone' => '+92 305 7890123',
                'emergency_contact' => '+92 366 4321098',
                'dept' => $deptEng->id,
                'desig' => $desLeadDev->id,
                'shift' => $shiftMorning->id,
                'salary' => 140000.00,
                'joining' => '2023-04-12',
                'avatar' => 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&auto=format&fit=crop',
                'status' => 'active',
            ],
        ];

        $createdUsers = [];
        foreach ($staffMembers as $s) {
            $user = User::updateOrCreate(
                ['email' => $s['email']],
                [
                    'employee_code' => $s['code'],
                    'name' => $s['name'],
                    'phone' => $s['phone'],
                    'emergency_contact' => $s['emergency_contact'],
                    'password' => Hash::make('password123'),
                    'department_id' => $s['dept'],
                    'designation_id' => $s['desig'],
                    'shift_id' => $s['shift'],
                    'basic_salary' => $s['salary'],
                    'role' => 'staff',
                    'status' => $s['status'],
                    'joining_date' => $s['joining'],
                    'avatar_url' => $s['avatar'],
                ]
            );
            $createdUsers[] = $user;
        }

        // 6. Office Location & Dynamic Kiosk QR
        OfficeLocation::updateOrCreate(
            ['id' => 1],
            [
                'name' => 'Verdant Precision HQ - Main Lobby',
                'qr_secret_key' => 'HRMS-OFFICE-LOBBY-SECURE-2026',
                'latitude' => 24.8607000,
                'longitude' => 67.0011000,
                'radius_meters' => 150,
                'is_active' => true,
            ]
        );

        // 7. Seed Past 5 Days Attendance
        $today = Carbon::today();
        for ($daysAgo = 4; $daysAgo >= 0; $daysAgo--) {
            $date = $today->copy()->subDays($daysAgo);
            $dateStr = $date->toDateString();

            foreach ($createdUsers as $index => $u) {
                // Different statuses per employee & day
                if ($daysAgo === 0) {
                    // Today
                    if ($index === 0) { // Ali Khan
                        Attendance::updateOrCreate(
                            ['user_id' => $u->id, 'date' => $dateStr],
                            ['check_in' => '09:05:00', 'check_out' => null, 'total_hours' => null, 'status' => 'present', 'check_in_note' => 'Main Gate Scanner']
                        );
                    } elseif ($index === 1) { // Sara Ahmed
                        Attendance::updateOrCreate(
                            ['user_id' => $u->id, 'date' => $dateStr],
                            ['check_in' => '08:58:00', 'check_out' => null, 'total_hours' => null, 'status' => 'present', 'check_in_note' => 'Lobby Kiosk']
                        );
                    } elseif ($index === 2) { // Hamza Malik
                        Attendance::updateOrCreate(
                            ['user_id' => $u->id, 'date' => $dateStr],
                            ['check_in' => '09:22:00', 'check_out' => null, 'total_hours' => null, 'status' => 'late', 'check_in_note' => 'Traffic on Highway']
                        );
                    } elseif ($index === 3) { // Zainab Tariq
                        Attendance::updateOrCreate(
                            ['user_id' => $u->id, 'date' => $dateStr],
                            ['check_in' => '13:50:00', 'check_out' => null, 'total_hours' => null, 'status' => 'present', 'check_in_note' => 'Evening Shift Early In']
                        );
                    } elseif ($index === 4) { // Bilal Hassan
                        Attendance::updateOrCreate(
                            ['user_id' => $u->id, 'date' => $dateStr],
                            ['check_in' => null, 'check_out' => null, 'total_hours' => 0.0, 'status' => 'absent', 'check_in_note' => 'Medical Leave Approved']
                        );
                    } elseif ($index === 5) { // Ayesha Siddiqui
                        Attendance::updateOrCreate(
                            ['user_id' => $u->id, 'date' => $dateStr],
                            ['check_in' => '09:00:00', 'check_out' => null, 'total_hours' => null, 'status' => 'present', 'check_in_note' => 'Lobby Kiosk Scanner']
                        );
                    }
                } else {
                    // Past completed days
                    $status = ($index === 4 && $daysAgo === 1) ? 'absent' : (($index === 2 && $daysAgo === 2) ? 'late' : 'present');
                    $cin = ($status === 'late') ? '09:25:00' : '09:02:00';
                    $cout = '18:05:00';
                    $hours = ($status === 'absent') ? 0.0 : 8.5;

                    Attendance::updateOrCreate(
                        ['user_id' => $u->id, 'date' => $dateStr],
                        [
                            'check_in' => ($status === 'absent') ? null : $cin,
                            'check_out' => ($status === 'absent') ? null : $cout,
                            'total_hours' => $hours,
                            'status' => $status,
                            'is_manual_override' => ($daysAgo === 2 && $index === 0),
                            'check_in_note' => ($daysAgo === 2 && $index === 0) ? 'Corrected by Admin' : 'Biometric Kiosk',
                        ]
                    );
                }
            }
        }

        // 8. Payroll for November 2026
        foreach ($createdUsers as $u) {
            $basic = (float) $u->basic_salary;
            $allowance = round($basic * 0.15, 2); // 15% allowance (transport + tech)
            $deductions = ($u->employee_code === 'EMP-003') ? 4500.00 : (($u->employee_code === 'EMP-005') ? 6000.00 : 0.00);
            $net = $basic + $allowance - $deductions;

            Payroll::updateOrCreate(
                ['user_id' => $u->id, 'month' => '2026-11'],
                [
                    'basic_salary' => $basic,
                    'allowances' => $allowance,
                    'deductions' => $deductions,
                    'net_salary' => $net,
                    'present_days' => 20,
                    'late_days' => ($u->employee_code === 'EMP-003') ? 3 : 0,
                    'absent_days' => ($u->employee_code === 'EMP-005') ? 2 : 0,
                    'status' => ($u->employee_code === 'EMP-001' || $u->employee_code === 'EMP-002') ? 'paid' : 'pending',
                    'payment_date' => ($u->employee_code === 'EMP-001' || $u->employee_code === 'EMP-002') ? '2026-11-20' : null,
                    'payment_method' => 'Direct Bank Transfer',
                    'notes' => 'Monthly payroll auto-calculated based on attendance register.',
                ]
            );
        }
    }
}
