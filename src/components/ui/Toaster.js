import { useState, useEffect } from 'react'
import { X, CheckCircle, AlertCircle, Info, AlertTriangle } from 'lucide-react'

let toastId = 0
const toasts = new Map()
const listeners = new Set()

const addToast = (toast) => {
  const id = ++toastId
  const toastWithId = { ...toast, id }
  toasts.set(id, toastWithId)
  
  listeners.forEach(listener => listener([...toasts.values()]))
  
  if (toast.duration !== 0) {
    setTimeout(() => {
      removeToast(id)
    }, toast.duration || 5000)
  }
  
  return id
}

const removeToast = (id) => {
  toasts.delete(id)
  listeners.forEach(listener => listener([...toasts.values()]))
}

export const toast = {
  success: (message, options = {}) => addToast({ type: 'success', message, ...options }),
  error: (message, options = {}) => addToast({ type: 'error', message, ...options }),
  warning: (message, options = {}) => addToast({ type: 'warning', message, ...options }),
  info: (message, options = {}) => addToast({ type: 'info', message, ...options }),
  dismiss: removeToast
}

const ToastIcon = ({ type }) => {
  const icons = {
    success: CheckCircle,
    error: AlertCircle,
    warning: AlertTriangle,
    info: Info
  }
  
  const Icon = icons[type]
  return <Icon className="w-5 h-5" />
}

const ToastItem = ({ toast, onRemove }) => {
  const typeStyles = {
    success: 'bg-green-50 border-green-200 text-green-800',
    error: 'bg-red-50 border-red-200 text-red-800',
    warning: 'bg-yellow-50 border-yellow-200 text-yellow-800',
    info: 'bg-blue-50 border-blue-200 text-blue-800'
  }

  return (
    <div className={`flex items-center gap-3 p-4 rounded-lg border shadow-lg ${typeStyles[toast.type]} animate-in slide-in-from-right duration-300`}>
      <ToastIcon type={toast.type} />
      <p className="flex-1 text-sm font-medium">{toast.message}</p>
      <button
        onClick={() => onRemove(toast.id)}
        className="text-gray-400 hover:text-gray-600 transition-colors"
      >
        <X className="w-4 h-4" />
      </button>
    </div>
  )
}

export const Toaster = () => {
  const [toastList, setToastList] = useState([])

  useEffect(() => {
    listeners.add(setToastList)
    return () => listeners.delete(setToastList)
  }, [])

  return (
    <div className="fixed top-4 right-4 z-50 space-y-2 max-w-sm w-full">
      {toastList.map(toast => (
        <ToastItem
          key={toast.id}
          toast={toast}
          onRemove={removeToast}
        />
      ))}
    </div>
  )
}