/**
 * Custom Radar Chart - No external dependencies
 * 3 INDEPENDENT controls:
 * - labelCircleRadius: where labels are positioned (does NOT affect radar)
 * - labelFontSize: text size of labels (does NOT affect anything else)
 * - radarRadius: size of the radar grid (does NOT affect labels)
 */

class CustomRadarChart {
    constructor(canvas, options = {}) {
        this.canvas = canvas;
        this.ctx = canvas.getContext('2d');
        
        // Device pixel ratio for sharp rendering
        this.dpr = window.devicePixelRatio || 1;
        
        // Data
        this.labels = options.labels || [];
        this.data = options.data || [];
        this.maxValue = options.maxValue || 10;
        
        // Colors
        this.lineColor = options.lineColor || '#00ffff';
        this.fillColor = options.fillColor || 'rgba(0, 255, 255, 0.2)';
        this.gridColor = options.gridColor || 'rgba(255, 255, 255, 0.1)';
        this.labelColor = options.labelColor || '#bbb';
        this.pointColors = options.pointColors || null;  // Array of colors per point (for combined chart)
        
        // 3 INDEPENDENT values - these NEVER affect each other
        this.labelHeight = options.labelHeight || 160;    // Label vertical radius (top/bottom)
        this.labelWidth = options.labelWidth || 120;      // Label horizontal radius (left/right)
        this.labelFontSize = options.labelFontSize || 11; // Label text size
        this.radarRadius = options.radarRadius || 120;    // Radar grid size
        
        // Other settings
        this.gridLevels = options.gridLevels || 5;
        this.pointRadius = options.pointRadius || 4;
        this.lineWidth = options.lineWidth || 2;
        
        // Label text padding (extra space for text width)
        this.labelTextPadding = 90;
        
        this.resize();
    }
    
    resize() {
        // Get actual display size from the canvas element itself
        const rect = this.canvas.getBoundingClientRect();
        const displayWidth = rect.width || 400;
        const displayHeight = rect.height || 400;
        const size = Math.min(displayWidth, displayHeight);
        
        if (size < 10) return; // Skip if too small
        
        this.dpr = window.devicePixelRatio || 1;
        
        // Set canvas internal resolution (for sharp text on HiDPI)
        const canvasSize = Math.round(size * this.dpr);
        this.canvas.width = canvasSize;
        this.canvas.height = canvasSize;
        
        // Let CSS handle display size
        
        this.size = size;
        this.centerX = size / 2;
        this.centerY = size / 2;
        
        // Calculate the maximum usable radius (leave space for labels)
        this.maxRadius = (size / 2) - this.labelTextPadding;
        if (this.maxRadius < 50) this.maxRadius = 50;
    }
    
    // Get actual pixel values - scaled to fit in canvas
    getScaledRadarRadius() {
        // radarRadius is also scaled to fit
        const minSlider = 60;
        const maxSlider = 150;
        const normalized = (this.radarRadius - minSlider) / (maxSlider - minSlider);
        // Map to 40% - 85% of maxRadius
        return this.maxRadius * (0.4 + normalized * 0.45);
    }
    
    setData(data) {
        this.data = data;
        this.draw();
    }
    
    // Set individual controls - each one ONLY affects its own value
    setLabelHeight(value) {
        this.labelHeight = value;
        this.draw();
    }
    
    setLabelWidth(value) {
        this.labelWidth = value;
        this.draw();
    }
    
    setLabelFontSize(value) {
        this.labelFontSize = value;
        this.draw();
    }
    
    setRadarRadius(value) {
        this.radarRadius = value;
        this.draw();
    }
    
    draw() {
        const ctx = this.ctx;
        const numPoints = this.labels.length;
        
        if (numPoints === 0) return;
        
        // Reset transform and scale for sharp rendering on HiDPI
        ctx.setTransform(this.dpr, 0, 0, this.dpr, 0, 0);
        
        // Clear canvas (in CSS pixels, not canvas pixels)
        ctx.clearRect(0, 0, this.size, this.size);
        
        const angleStep = (2 * Math.PI) / numPoints;
        const startAngle = -Math.PI / 2; // Start from top
        
        // Draw grid circles - uses ONLY radarRadius
        this.drawGrid(ctx, numPoints, angleStep, startAngle);
        
        // Draw axis lines - uses ONLY radarRadius
        this.drawAxisLines(ctx, numPoints, angleStep, startAngle);
        
        // Draw data polygon - uses ONLY radarRadius
        this.drawDataPolygon(ctx, numPoints, angleStep, startAngle);
        
        // Draw labels - uses ONLY labelCircleRadius and labelFontSize
        this.drawLabels(ctx, numPoints, angleStep, startAngle);
    }
    
    drawGrid(ctx, numPoints, angleStep, startAngle) {
        ctx.strokeStyle = this.gridColor;
        ctx.lineWidth = 1;
        
        const actualRadarRadius = this.getScaledRadarRadius();
        
        for (let level = 1; level <= this.gridLevels; level++) {
            const levelRadius = (actualRadarRadius / this.gridLevels) * level;
            
            ctx.beginPath();
            for (let i = 0; i <= numPoints; i++) {
                const angle = startAngle + (i % numPoints) * angleStep;
                const x = this.centerX + Math.cos(angle) * levelRadius;
                const y = this.centerY + Math.sin(angle) * levelRadius;
                
                if (i === 0) {
                    ctx.moveTo(x, y);
                } else {
                    ctx.lineTo(x, y);
                }
            }
            ctx.closePath();
            ctx.stroke();
        }
    }
    
    drawAxisLines(ctx, numPoints, angleStep, startAngle) {
        ctx.strokeStyle = this.gridColor;
        ctx.lineWidth = 1;
        
        const actualRadarRadius = this.getScaledRadarRadius();
        
        for (let i = 0; i < numPoints; i++) {
            const angle = startAngle + i * angleStep;
            const x = this.centerX + Math.cos(angle) * actualRadarRadius;
            const y = this.centerY + Math.sin(angle) * actualRadarRadius;
            
            ctx.beginPath();
            ctx.moveTo(this.centerX, this.centerY);
            ctx.lineTo(x, y);
            ctx.stroke();
        }
    }
    
    drawDataPolygon(ctx, numPoints, angleStep, startAngle) {
        if (this.data.length === 0) return;
        
        const actualRadarRadius = this.getScaledRadarRadius();
        const points = [];
        
        // Calculate points
        for (let i = 0; i < numPoints; i++) {
            const angle = startAngle + i * angleStep;
            const value = this.data[i] || 0;
            const normalizedValue = value / this.maxValue;
            const pointRadius = normalizedValue * actualRadarRadius;
            
            points.push({
                x: this.centerX + Math.cos(angle) * pointRadius,
                y: this.centerY + Math.sin(angle) * pointRadius
            });
        }
        
        // Draw filled polygon
        ctx.beginPath();
        ctx.fillStyle = this.fillColor;
        points.forEach((point, i) => {
            if (i === 0) {
                ctx.moveTo(point.x, point.y);
            } else {
                ctx.lineTo(point.x, point.y);
            }
        });
        ctx.closePath();
        ctx.fill();
        
        // Draw border
        ctx.beginPath();
        ctx.strokeStyle = this.lineColor;
        ctx.lineWidth = this.lineWidth;
        points.forEach((point, i) => {
            if (i === 0) {
                ctx.moveTo(point.x, point.y);
            } else {
                ctx.lineTo(point.x, point.y);
            }
        });
        ctx.closePath();
        ctx.stroke();
        
        // Draw points
        points.forEach((point, i) => {
            // Use individual point color if available, otherwise use lineColor
            const pointColor = (this.pointColors && this.pointColors[i]) ? this.pointColors[i] : this.lineColor;
            ctx.fillStyle = pointColor;
            ctx.beginPath();
            ctx.arc(point.x, point.y, this.pointRadius, 0, 2 * Math.PI);
            ctx.fill();
            
            // White border on points
            ctx.strokeStyle = '#fff';
            ctx.lineWidth = 1;
            ctx.stroke();
        });
    }
    
    drawLabels(ctx, numPoints, angleStep, startAngle) {
        ctx.fillStyle = this.labelColor;
        ctx.font = `${this.labelFontSize}px "Segoe UI", Tahoma, Geneva, Verdana, sans-serif`;
        ctx.textBaseline = 'middle';
        
        // Direct pixel values for height and width
        const verticalRadius = this.labelHeight;
        const horizontalRadius = this.labelWidth;
        
        for (let i = 0; i < numPoints; i++) {
            const angle = startAngle + i * angleStep;
            // Oval: different radii for x and y
            const x = this.centerX + Math.cos(angle) * horizontalRadius;
            const y = this.centerY + Math.sin(angle) * verticalRadius;
            
            const label = this.labels[i] || '';
            
            // Determine text alignment based on position
            if (Math.abs(Math.cos(angle)) < 0.1) {
                // Top or bottom
                ctx.textAlign = 'center';
            } else if (Math.cos(angle) > 0) {
                // Right side
                ctx.textAlign = 'left';
            } else {
                // Left side
                ctx.textAlign = 'right';
            }
            
            ctx.fillText(label, x, y);
        }
    }
}

// Export for use
window.CustomRadarChart = CustomRadarChart;
