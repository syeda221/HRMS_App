<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Attendance extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'date',
        'check_in',
        'check_out',
        'total_hours',
        'status',
        'check_in_note',
        'check_out_note',
    ];

    protected $casts = [
        'date' => 'date',
        'total_hours' => 'float',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
