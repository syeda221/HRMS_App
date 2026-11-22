<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Shift;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AdminShiftController extends Controller
{
    /**
     * List all shifts with staff counts
     */
    public function index(): JsonResponse
    {
        $shifts = Shift::withCount('users')->get()->map(function ($s) {
            return [
                'id' => $s->id,
                'name' => $s->name,
                'start_time' => substr($s->start_time, 0, 5),
                'end_time' => substr($s->end_time, 0, 5),
                'grace_period_mins' => $s->grace_period_mins,
                'required_hours' => (float) $s->required_hours,
                'working_days' => $s->working_days,
                'is_active' => (bool) $s->is_active,
                'assigned_staff_count' => $s->users_count,
            ];
        });

        return response()->json([
            'status' => true,
            'message' => 'Shifts list retrieved successfully.',
            'data' => [
                'total_shifts' => $shifts->count(),
                'active_shifts' => $shifts->where('is_active', true)->count(),
                'shifts' => $shifts,
            ],
        ]);
    }

    /**
     * Store new shift
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'start_time' => 'required|date_format:H:i',
            'end_time' => 'required|date_format:H:i',
            'grace_period_mins' => 'nullable|integer|min:0|max:120',
            'required_hours' => 'nullable|numeric|min:1|max:24',
            'working_days' => 'nullable|string',
            'is_active' => 'nullable|boolean',
        ]);

        $shift = Shift::create([
            'name' => $validated['name'],
            'start_time' => $validated['start_time'] . ':00',
            'end_time' => $validated['end_time'] . ':00',
            'grace_period_mins' => $validated['grace_period_mins'] ?? 15,
            'required_hours' => $validated['required_hours'] ?? 8.0,
            'working_days' => $validated['working_days'] ?? 'Mon - Fri',
            'is_active' => $validated['is_active'] ?? true,
        ]);

        return response()->json([
            'status' => true,
            'message' => 'New shift registered successfully.',
            'data' => $shift,
        ], 201);
    }

    /**
     * Update shift timings
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $shift = Shift::findOrFail($id);

        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'start_time' => 'sometimes|date_format:H:i',
            'end_time' => 'sometimes|date_format:H:i',
            'grace_period_mins' => 'nullable|integer|min:0|max:120',
            'required_hours' => 'nullable|numeric|min:1|max:24',
            'working_days' => 'nullable|string',
            'is_active' => 'nullable|boolean',
        ]);

        if (isset($validated['start_time']) && strlen($validated['start_time']) === 5) {
            $validated['start_time'] .= ':00';
        }
        if (isset($validated['end_time']) && strlen($validated['end_time']) === 5) {
            $validated['end_time'] .= ':00';
        }

        $shift->update($validated);

        return response()->json([
            'status' => true,
            'message' => 'Shift updated successfully.',
            'data' => $shift,
        ]);
    }

    /**
     * Delete shift
     */
    public function destroy(int $id): JsonResponse
    {
        $shift = Shift::withCount('users')->findOrFail($id);

        if ($shift->users_count > 0) {
            return response()->json([
                'status' => false,
                'message' => "Cannot delete shift: {$shift->users_count} employees are currently assigned to it.",
            ], 422);
        }

        $shift->delete();

        return response()->json([
            'status' => true,
            'message' => 'Shift removed successfully.',
        ]);
    }
}
