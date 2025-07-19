import { createMiddlewareClient } from '@supabase/auth-helpers-nextjs'
import { NextResponse } from 'next/server'

export async function middleware(req) {
  const res = NextResponse.next()
  const supabase = createMiddlewareClient({ req, res })

  const {
    data: { session },
  } = await supabase.auth.getSession()

  // Protected routes that require authentication
  const protectedRoutes = [
    '/dashboard',
    '/profile',
    '/create',
    '/admin',
    '/editor',
    '/quiz/create',
    '/settings'
  ]

  // Admin only routes
  const adminRoutes = [
    '/admin',
    '/admin/users',
    '/admin/content',
    '/admin/categories',
    '/admin/analytics'
  ]

  // Editor routes
  const editorRoutes = [
    '/editor',
    '/editor/review',
    '/editor/pending'
  ]

  const { pathname } = req.nextUrl

  // Check if route is protected
  const isProtectedRoute = protectedRoutes.some(route => 
    pathname.startsWith(route)
  )

  const isAdminRoute = adminRoutes.some(route => 
    pathname.startsWith(route)
  )

  const isEditorRoute = editorRoutes.some(route => 
    pathname.startsWith(route)
  )

  // Redirect to login if accessing protected route without session
  if (isProtectedRoute && !session) {
    const redirectUrl = new URL('/auth/signin', req.url)
    redirectUrl.searchParams.set('redirectTo', pathname)
    return NextResponse.redirect(redirectUrl)
  }

  // Check user role for admin/editor routes
  if (session && (isAdminRoute || isEditorRoute)) {
    const { data: profile } = await supabase
      .from('profiles')
      .select('role')
      .eq('id', session.user.id)
      .single()

    if (!profile) {
      return NextResponse.redirect(new URL('/auth/signin', req.url))
    }

    // Check admin access
    if (isAdminRoute) {
      const adminRoles = ['superadmin', 'admin']
      if (!adminRoles.includes(profile.role)) {
        return NextResponse.redirect(new URL('/dashboard', req.url))
      }
    }

    // Check editor access
    if (isEditorRoute) {
      const editorRoles = ['superadmin', 'admin', 'editor', 'legaleditor']
      if (!editorRoles.includes(profile.role)) {
        return NextResponse.redirect(new URL('/dashboard', req.url))
      }
    }
  }

  // Redirect authenticated users away from auth pages
  if (session && pathname.startsWith('/auth/')) {
    return NextResponse.redirect(new URL('/dashboard', req.url))
  }

  return res
}

export const config = {
  matcher: [
    '/((?!api|_next/static|_next/image|favicon.ico).*)',
  ],
}