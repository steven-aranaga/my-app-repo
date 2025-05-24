// Main JavaScript for My App

'use strict';

// Wait for DOM to be fully loaded
document.addEventListener('DOMContentLoaded', function() {
  console.log('My App loaded');
  
  // Initialize components
  initializeApp();
});

/**
 * Initialize the application
 */
function initializeApp() {
  // Add active class to current nav item
  highlightCurrentNavItem();
  
  // Initialize form handlers if forms exist
  initializeForms();
  
  // Initialize HTMX elements
  initializeHtmx();
}

/**
 * Highlight the current navigation item based on URL
 */
function highlightCurrentNavItem() {
  const currentPath = window.location.pathname;
  const navLinks = document.querySelectorAll('.nav-links a');
  
  navLinks.forEach(link => {
    if (link.getAttribute('href') === currentPath) {
      link.parentElement.classList.add('active');
    }
  });
}

/**
 * Initialize form validation and submission
 */
function initializeForms() {
  const forms = document.querySelectorAll('form');
  
  forms.forEach(form => {
    form.addEventListener('submit', function(event) {
      if (!validateForm(form)) {
        event.preventDefault();
      }
    });
  });
}

/**
 * Validate form inputs
 * @param {HTMLFormElement} form - The form to validate
 * @returns {boolean} - Whether the form is valid
 */
function validateForm(form) {
  let isValid = true;
  const requiredInputs = form.querySelectorAll('[required]');
  
  requiredInputs.forEach(input => {
    if (!input.value.trim()) {
      isValid = false;
      showError(input, 'This field is required');
    } else {
      clearError(input);
    }
  });
  
  return isValid;
}

/**
 * Show error message for an input
 * @param {HTMLElement} input - The input element
 * @param {string} message - The error message
 */
function showError(input, message) {
  const formGroup = input.closest('.form-group');
  let errorElement = formGroup.querySelector('.error-message');
  
  if (!errorElement) {
    errorElement = document.createElement('div');
    errorElement.className = 'error-message';
    errorElement.style.color = 'red';
    errorElement.style.fontSize = '0.875rem';
    errorElement.style.marginTop = '0.25rem';
    formGroup.appendChild(errorElement);
  }
  
  errorElement.textContent = message;
  input.classList.add('is-invalid');
}

/**
 * Clear error message for an input
 * @param {HTMLElement} input - The input element
 */
function clearError(input) {
  const formGroup = input.closest('.form-group');
  const errorElement = formGroup.querySelector('.error-message');
  
  if (errorElement) {
    errorElement.textContent = '';
  }
  
  input.classList.remove('is-invalid');
}

/**
 * Initialize HTMX elements if HTMX is loaded
 */
function initializeHtmx() {
  // Check if HTMX is available
  if (typeof htmx !== 'undefined') {
    // HTMX is loaded, initialize custom events
    document.body.addEventListener('htmx:configRequest', function(event) {
      // Add CSRF token to all HTMX requests if available
      const csrfToken = document.querySelector('meta[name="csrf-token"]');
      if (csrfToken) {
        event.detail.headers['X-CSRF-Token'] = csrfToken.content;
      }
    });
    
    document.body.addEventListener('htmx:afterSwap', function(event) {
      // Re-initialize components after HTMX content swap
      highlightCurrentNavItem();
      initializeForms();
    });
  }
}

