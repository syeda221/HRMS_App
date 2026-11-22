<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 1. Add salary and address/emergency contact fields to users
        Schema::table('users', function (Blueprint $table) {
            $table->decimal('basic_salary', 10, 2)->default(50000.00)->after('status');
            $table->string('emergency_contact')->nullable()->after('phone');
        });

        // 2. Add manual override to attendances
        Schema::table('attendances', function (Blueprint $table) {
            $table->boolean('is_manual_override')->default(false)->after('status');
            $table->foreignId('overridden_by')->nullable()->after('is_manual_override')->constrained('users')->nullOnDelete();
        });

        // 3. Create payrolls table
        Schema::create('payrolls', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('month'); // e.g. "2026-11"
            $table->decimal('basic_salary', 10, 2)->default(0.00);
            $table->decimal('allowances', 10, 2)->default(0.00);
            $table->decimal('deductions', 10, 2)->default(0.00);
            $table->decimal('net_salary', 10, 2)->default(0.00);
            $table->integer('present_days')->default(0);
            $table->integer('late_days')->default(0);
            $table->integer('absent_days')->default(0);
            $table->enum('status', ['paid', 'pending', 'processing'])->default('pending');
            $table->date('payment_date')->nullable();
            $table->string('payment_method')->default('Direct Deposit');
            $table->text('notes')->nullable();
            $table->timestamps();

            $table->unique(['user_id', 'month']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('payrolls');

        Schema::table('attendances', function (Blueprint $table) {
            $table->dropForeign(['overridden_by']);
            $table->dropColumn(['is_manual_override', 'overridden_by']);
        });

        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['basic_salary', 'emergency_contact']);
        });
    }
};
