import { createPeriodFromQuarter } from './queryHelper'

describe('queryHelper', () => {
  describe('createPeriodFromQuarter', () => {
    afterEach(() => {
      jest.useRealTimers()
    })

    it('should return date range for q1', () => {
      jest.useFakeTimers("modern");
      jest.setSystemTime(new Date(1578958478000));
      const dateRange = createPeriodFromQuarter('q1')
      expect(dateRange.start).toMatch(/^2026-01-01T/)
    })

    it('should return full year range for full-2026', () => {
      const dateRange = createPeriodFromQuarter('full-2026')
      expect(dateRange.start).toMatch(/^2026-01-01T/)
      expect(dateRange.end).toMatch(/^2026-12-31T/)
    })
  })
  
})