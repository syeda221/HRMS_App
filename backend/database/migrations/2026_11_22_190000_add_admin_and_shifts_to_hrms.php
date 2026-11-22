<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 1. Shifts table
        Schema::create('shifts', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->time('start_time')->default('09:00:00');
            $table->time('end_time')->default('18:00:00');
            $table->integer('grace_period_mins')->default(15);
            $table->decimal('required_hours', 4, 2)->default(8.0);
            $table->string('working_days')->default('Mon - Fri');
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        // 2. Add role and shift_id to users
        Schema::table('users', function (Blueprint $table) {
            $table->enum('role', ['admin', 'staff'])->default('staff')->after('password');
            $table->foreignId('shift_id')->nullable()->after('designation_id')->constrained('shifts')->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropForeign(['shift_id']);
            $table->dropColumn(['role', 'shift_id']);
        });

        Schema::dropIfExists('shifts');
    }
};
