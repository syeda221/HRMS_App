<?php

namespace Database\Seeders;

use App\Models\Attendance;
use App\Models\Department;
use App\Models\Designation;
use App\Models\Holiday;
use App\Models\OfficeLocation;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AttendanceSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // 1. Create Departments
        $eng = Department::firstOrCreate(['code' => 'ENG'], ['name' => 'Engineering']);
        $design = Department::firstOrCreate(['code' => 'DES'], ['name' => 'Product Design']);
        $ops = Department::firstOrCreate(['code' => 'OPS'], ['name' => 'Operations']);
        $hr = Department::firstOrCreate(['code' => 'HR'], ['name' => 'Human Resources']);

        // 2. Create Designations
        $devDesig = Designation::firstOrCreate(['title' => 'Senior Flutter Engineer', 'department_id' => $eng->id]);
        $uiDesig = Designation::firstOrCreate(['title' => 'Product Designer', 'department_id' => $design->id]);
        $leadDesig = Designation::firstOrCreate(['title' => 'Operations Lead', 'department_id' => $ops->id]);

        // 3. Create Office QR Location
        $office = OfficeLocation::firstOrCreate(
            ['qr_secret_key' => 'STITCH-OFFICE-HQ-2026'],
            [
                'name' => 'Headquarters - Main Lobby',
                'latitude' => 31.5204,
                'longitude' => 74.3587,
                'radius_meters' => 150,
                'is_active' => true,
            ]
        );

        // 4. Create Staff Member (Demo User)
        $staff = User::updateOrCreate(
            ['email' => 'staff@company.com'],
            [
                'employee_code' => 'EMP-1042',
                'name' => 'Alex Morgan',
                'phone' => '+1 (555) 382-9102',
                'password' => Hash::make('password123'),
                'department_id' => $eng->id,
                'designation_id' => $devDesig->id,
                'joining_date' => Carbon::now()->subMonths(14)->toDateString(),
                'avatar_url' => 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=300',
                'status' => 'active',
            ]
        );

        // 5. Seed Holidays
        Holiday::firstOrCreate(
            ['date' => Carbon::now()->subDays(12)->toDateString()],
            ['title' => 'Corporate Innovation Day', 'type' => 'company']
        );

        // 6. Seed exactly 25 days of realistic attendance history
        $startDate = Carbon::now()->subDays(25);
        $endDate = Carbon::now()->subDay(); // up to yesterday

        $current = $startDate->copy();
        $seededDays = 0;

        while ($current->lte($endDate) && $seededDays < 25) {
            $dateStr = $current->toDateString();
            $isWeekend = $current->isWeekend();

            if ($isWeekend) {
                // Weekend holiday record
                Attendance::updateOrCreate(
                    ['user_id' => $staff->id, 'date' => $dateStr],
                    [
                        'check_in' => null,
                        'check_out' => null,
                        'total_hours' => 0,
                        'status' => 'holiday',
                        'check_in_note' => 'Weekend',
                    ]
                );
            } elseif ($current->isSameDay(Carbon::now()->subDays(12))) {
                // Company holiday
                Attendance::updateOrCreate(
                    ['user_id' => $staff->id, 'date' => $dateStr],
                    [
                        'check_in' => null,
                        'check_out' => null,
                        'total_hours' => 0,
                        'status' => 'holiday',
                        'check_in_note' => 'Corporate Innovation Day',
                    ]
                );
            } elseif ($current->isSameDay(Carbon::now()->subDays(7))) {
                // 1 Absent day for realistic reporting
                Attendance::updateOrCreate(
                    ['user_id' => $staff->id, 'date' => $dateStr],
                    [
                        'check_in' => null,
                        'check_out' => null,
                        'total_hours' => 0,
                        'status' => 'absent',
                        'check_in_note' => 'Approved Casual Leave',
                    ]
                );
            } else {
                // Regular Working Day: 80% Present on-time, 20% Late
                $isLate = ($seededDays % 5 == 2); // periodic late day

                if ($isLate) {
                    $inMinute = rand(10, 28);
                    $checkInTime = sprintf('09:%02d:00', $inMinute);
                    $status = 'late';
                } else {
                    $inMinute = rand(45, 58);
                    $checkInTime = sprintf('08:%02d:00', $inMinute);
                    $status = 'present';
                }

                $outHour = rand(17, 18);
                $outMinute = rand(15, 45);
                $checkOutTime = sprintf('%02d:%02d:00', $outHour, $outMinute);

                // Calculate working hours
                $inCarbon = Carbon::parse("$dateStr $checkInTime");
                $outCarbon = Carbon::parse("$dateStr $checkOutTime");
                $hours = abs(round($outCarbon->diffInMinutes($inCarbon) / 60, 2));

                Attendance::updateOrCreate(
                    ['user_id' => $staff->id, 'date' => $dateStr],
                    [
                        'check_in' => $checkInTime,
                        'check_out' => $checkOutTime,
                        'total_hours' => $hours,
                        'status' => $status,
                        'check_in_note' => 'QR Check-in at Main Lobby',
                        'check_out_note' => 'QR Check-out',
                    ]
                );
            }

            $current->addDay();
            $seededDays++;
        }
    }
}
