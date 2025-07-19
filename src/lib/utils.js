import { clsx } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs) {
  return twMerge(clsx(inputs))
}

export function formatDate(date) {
  return new Date(date).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

export function formatRelativeTime(date) {
  const now = new Date()
  const diff = now - new Date(date)
  const seconds = Math.floor(diff / 1000)
  const minutes = Math.floor(seconds / 60)
  const hours = Math.floor(minutes / 60)
  const days = Math.floor(hours / 24)

  if (days > 0) return `${days} day${days > 1 ? 's' : ''} ago`
  if (hours > 0) return `${hours} hour${hours > 1 ? 's' : ''} ago`
  if (minutes > 0) return `${minutes} minute${minutes > 1 ? 's' : ''} ago`
  return 'Just now'
}

export function calculateReadingTime(content) {
  const wordsPerMinute = 200
  const words = content.trim().split(/\s+/).length
  return Math.ceil(words / wordsPerMinute)
}

export function generateSlug(title) {
  return title
    .toLowerCase()
    .replace(/[^\w\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
    .trim()
}

export function truncateText(text, maxLength = 150) {
  if (text.length <= maxLength) return text
  return text.substring(0, maxLength).trim() + '...'
}

export function getInitials(name) {
  return name
    .split(' ')
    .map(word => word[0])
    .join('')
    .toUpperCase()
    .slice(0, 2)
}

export function validateEmail(email) {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  return emailRegex.test(email)
}

export function validatePassword(password) {
  // At least 8 characters, 1 uppercase, 1 lowercase, 1 number
  const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$/
  return passwordRegex.test(password)
}

export const ROLES = {
  SUPERADMIN: 'superadmin',
  ADMIN: 'admin',
  AUTHOR: 'author',
  CONTRIBUTOR: 'contributor',
  EDITOR: 'editor',
  LEGALEDITOR: 'legaleditor',
  MODERATOR: 'moderator',
  USER: 'user'
}

export const CONTENT_STATUS = {
  DRAFT: 'draft',
  PENDING_REVIEW: 'pending_review',
  UNDER_REVIEW: 'under_review',
  APPROVED: 'approved',
  PUBLISHED: 'published',
  REJECTED: 'rejected',
  ARCHIVED: 'archived'
}

export const CONTENT_TYPES = {
  ARTICLE: 'article',
  OPINION: 'opinion',
  INTERVIEW: 'interview',
  POEM: 'poem',
  BLOG: 'blog',
  NEWS: 'news',
  TUTORIAL: 'tutorial'
}

export function hasPermission(userRole, requiredRoles) {
  if (!userRole || !requiredRoles) return false
  return requiredRoles.includes(userRole)
}

export function canEditContent(userRole, authorId, userId) {
  const editorRoles = [ROLES.SUPERADMIN, ROLES.ADMIN, ROLES.EDITOR, ROLES.LEGALEDITOR]
  return authorId === userId || hasPermission(userRole, editorRoles)
}

export function canPublishContent(userRole) {
  const publisherRoles = [ROLES.SUPERADMIN, ROLES.ADMIN, ROLES.EDITOR]
  return hasPermission(userRole, publisherRoles)
}