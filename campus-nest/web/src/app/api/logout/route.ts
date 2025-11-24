import { NextResponse } from "next/server";

export async function POST() {
    const res = NextResponse.json({ success: true, message: "Logged out" }, { status: 200 });

    res.cookies.set({
        name: "auth_token",
        value: "",
        httpOnly: true,
        path: "/",
        sameSite: "lax",
        secure: true,
        expires: new Date(0),
    });

    return res;
}

export async function GET() {
    const res = NextResponse.json({ success: true, message: "Logged out" }, { status: 200 });
    res.cookies.set({
        name: "auth_token",
        value: "",
        httpOnly: true,
        path: "/",
        sameSite: "lax",
        secure: true,
        expires: new Date(0),
    });
    return res;
}