#!/usr/bin/env python3
"""
Full Screen Clock for Raspberry Pi with Waveshare TFT Display
Displays current time in a clean, readable format
"""

import pygame
import sys
import os
from datetime import datetime

# Initialize Pygame
pygame.init()

# Display settings
DISPLAY_WIDTH = 320
DISPLAY_HEIGHT = 240
FPS = 1  # Update once per second

# Colors
BLACK = (0, 0, 0)
WHITE = (255, 255, 255)
GRAY = (128, 128, 128)

# Set up display - use framebuffer for TFT displays
os.environ['SDL_VIDEODRIVER'] = 'fbcon'
os.environ['SDL_FBDEV'] = '/dev/fb1'  # Waveshare TFT typically uses fb1

try:
    screen = pygame.display.set_mode((DISPLAY_WIDTH, DISPLAY_HEIGHT))
    pygame.display.set_caption('TFT Clock')
    pygame.mouse.set_visible(False)  # Hide cursor for clean display
except Exception as e:
    print(f"Display initialization failed: {e}")
    print("Falling back to windowed mode for testing...")
    os.environ['SDL_VIDEODRIVER'] = 'x11'
    screen = pygame.display.set_mode((DISPLAY_WIDTH, DISPLAY_HEIGHT))

clock = pygame.time.Clock()

def draw_clock(screen):
    """Draw the current time on screen"""
    screen.fill(BLACK)
    
    # Get current time
    now = datetime.now()
    time_str = now.strftime("%H:%M:%S")
    date_str = now.strftime("%A, %B %d, %Y")
    
    # Font sizes
    time_font = pygame.font.Font(None, 80)
    date_font = pygame.font.Font(None, 30)
    
    # Render time
    time_surface = time_font.render(time_str, True, WHITE)
    time_rect = time_surface.get_rect(center=(DISPLAY_WIDTH // 2, DISPLAY_HEIGHT // 2 - 20))
    
    # Render date
    date_surface = date_font.render(date_str, True, GRAY)
    date_rect = date_surface.get_rect(center=(DISPLAY_WIDTH // 2, DISPLAY_HEIGHT // 2 + 40))
    
    # Draw to screen
    screen.blit(time_surface, time_rect)
    screen.blit(date_surface, date_rect)
    
    pygame.display.flip()

def main():
    """Main loop"""
    running = True
    
    print("TFT Clock started. Press Ctrl+C to exit.")
    
    try:
        while running:
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    running = False
                elif event.type == pygame.KEYDOWN:
                    if event.key == pygame.K_ESCAPE or event.key == pygame.K_q:
                        running = False
            
            draw_clock(screen)
            clock.tick(FPS)
            
    except KeyboardInterrupt:
        print("\nClock stopped by user.")
    finally:
        pygame.quit()
        sys.exit(0)

if __name__ == "__main__":
    main()
