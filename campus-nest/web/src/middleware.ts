// middleware.ts
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

const loginPageUrl = '/login'
const dashboardUrl = '/admin/dashboard'

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl
  const token = request.cookies.get('auth_token')?.value
  
  if (pathname === '/') {
    const url = request.nextUrl.clone()
    url.pathname = dashboardUrl
    return NextResponse.redirect(url)
  }

  if (pathname === loginPageUrl && token) {
    const url = request.nextUrl.clone()
    url.pathname = dashboardUrl
    return NextResponse.redirect(url)
  }
  if (pathname.startsWith('/admin')) {
    if (!token) {
      const url = request.nextUrl.clone()
      url.pathname = loginPageUrl
      url.searchParams.set('from', pathname)
      return NextResponse.redirect(url)
    }
  }

  return NextResponse.next()
}

export const config = {
  matcher: ['/((?!api|_next/static|_next/image|favicon.ico).*)'],
}
