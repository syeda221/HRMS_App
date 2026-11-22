<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\OfficeLocation;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class AdminOfficeQrController extends Controller
{
    /**
     * Get Office QR kiosk settings and printable poster payload
     */
    public function getOfficeQr(): JsonResponse
    {
        $office = OfficeLocation::firstOrCreate(
            ['id' => 1],
            [
                'name' => 'HQ Main Lobby & Kiosk',
                'qr_secret_key' => 'HRMS-OFFICE-LOBBY-SECURE-2026',
                'latitude' => 24.8607000,
                'longitude' => 67.0011000,
                'radius_meters' => 150,
                'is_active' => true,
            ]
        );

        $qrPayload = json_encode([
            'system' => 'HRMS-VERDANT-KIOSK',
            'terminal_id' => 'HQ-LOBBY-01',
            'secret_key' => $office->qr_secret_key,
            'latitude' => (float) $office->latitude,
            'longitude' => (float) $office->longitude,
            'radius_meters' => $office->radius_meters,
            'timestamp' => Carbon::now()->toIso8601String(),
        ]);

        return response()->json([
            'status' => true,
            'message' => 'Office QR configuration retrieved.',
            'data' => [
                'office_id' => $office->id,
                'name' => $office->name,
                'qr_secret_key' => $office->qr_secret_key,
                'qr_payload' => $qrPayload,
                'latitude' => (float) $office->latitude,
                'longitude' => (float) $office->longitude,
                'radius_meters' => $office->radius_meters,
                'is_active' => (bool) $office->is_active,
                'last_regenerated' => $office->updated_at ? $office->updated_at->diffForHumans() : 'Recently',
            ],
        ]);
    }

    /**
     * Regenerate new QR Secret Key
     */
    public function regenerate(): JsonResponse
    {
        $office = OfficeLocation::firstOrFail();
        $newKey = 'HRMS-KEY-' . strtoupper(Str::random(12)) . '-' . Carbon::now()->format('His');

        $office->update([
            'qr_secret_key' => $newKey,
        ]);

        return $this->getOfficeQr();
    }

    /**
     * Update geofence coordinates and radius
     */
    public function updateGeofence(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'radius_meters' => 'required|integer|min:20|max:1000',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
        ]);

        $office = OfficeLocation::firstOrFail();
        $office->update($validated);

        return response()->json([
            'status' => true,
            'message' => 'Spatial Geofence parameters updated successfully.',
            'data' => $office,
        ]);
    }
}
