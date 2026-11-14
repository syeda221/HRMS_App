<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // 1. Departments
        Schema::create('departments', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('code')->unique();
            $table->timestamps();
        });

        // 2. Designations
        Schema::create('designations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('department_id')->nullable()->constrained('departments')->nullOnDelete();
            $table->string('title');
            $table->timestamps();
        });

        // 3. Update Users table with employee fields
        Schema::table('users', function (Blueprint $table) {
            $table->string('employee_code')->unique()->nullable()->after('id');
            $table->string('phone')->nullable()->after('email');
            $table->foreignId('department_id')->nullable()->after('phone')->constrained('departments')->nullOnDelete();
            $table->foreignId('designation_id')->nullable()->after('department_id')->constrained('designations')->nullOnDelete();
            $table->date('joining_date')->nullable()->after('designation_id');
            $table->string('avatar_url')->nullable()->after('joining_date');
            $table->enum('status', ['active', 'inactive'])->default('active')->after('avatar_url');
        });

        // 4. Office Locations & QR Code
        Schema::create('office_locations', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('qr_secret_key')->unique();
            $table->decimal('latitude', 10, 7)->nullable();
            $table->decimal('longitude', 10, 7)->nullable();
            $table->integer('radius_meters')->default(100);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        // 5. Attendances
        Schema::create('attendances', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->date('date');
            $table->time('check_in')->nullable();
            $table->time('check_out')->nullable();
            $table->decimal('total_hours', 4, 2)->nullable();
            $table->enum('status', ['present', 'late', 'absent', 'half_day', 'holiday'])->default('present');
            $table->string('check_in_note')->nullable();
            $table->string('check_out_note')->nullable();
            $table->timestamps();

            $table->unique(['user_id', 'date']);
        });

        // 6. Holidays
        Schema::create('holidays', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->date('date')->unique();
            $table->string('type')->default('company'); // national, company, weekend
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('holidays');
        Schema::dropIfExists('attendances');
        Schema::dropIfExists('office_locations');

        Schema::table('users', function (Blueprint $table) {
            $table->dropForeign(['department_id']);
            $table->dropForeign(['designation_id']);
            $table->dropColumn([
                'employee_code',
                'phone',
                'department_id',
                'designation_id',
                'joining_date',
                'avatar_url',
                'status'
            ]);
        });

        Schema::dropIfExists('designations');
        Schema::dropIfExists('departments');
    }
};
